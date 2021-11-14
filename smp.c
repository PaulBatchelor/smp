#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sndkit/lil.h>
#include <sndkit/patchwerk.h>
#include <sndkit/core.h>
#include <sndkit/sklil.h>
#include <sndkit/dr_wav.h>
#include <sqlite3.h>
#include <zlib.h>

void smp_open_db(const char *filename);
sqlite3 * smp_db(void);

static const char *ergohex = "0??2a3?4d567??ef8b1?c?9";
static void ergo_to_hex(const char *ergo, int sz, char *hex)
{
    int i;
    for (i = 0; i < sz; i++) {
        if (ergo[i] >= 'a' && ergo[i] <= 'w') {
            int pos = ergo[i] - 'a';
            hex[i] = ergohex[pos];
        } else {
            hex[i] = ergo[i];
        }
    }
}

/* based on sqlar utility */

static int sqlar_extract_to_buffer_db(sqlite3 *db,
                               const char *name,
                               char **out,
                               int *size)
{
    char *output;
    unsigned long int out_size;
    int rc;
    sqlite3_stmt *stmt;
    int sz;
    const char *data;
    int data_sz;

    rc = sqlite3_exec(db,
                      "CREATE TABLE IF NOT EXISTS sqlar(\n"
                      "  name TEXT PRIMARY KEY,\n"
                      "  mode INT,\n"
                      "  mtime INT,\n"
                      "  sz INT,\n"
                      "  data BLOB\n"
                      ");", 0, 0, 0);


    sqlite3_prepare(db,
                    "SELECT name, mode, mtime, sz, data FROM sqlar"
                    " WHERE name is ?1",
                    -1,
                    &stmt,
                    NULL);

    sqlite3_bind_text(stmt, 1, name, -1, SQLITE_STATIC);

    rc = sqlite3_step(stmt);

    if(rc != SQLITE_ROW) {
        fprintf(stderr,
                "SQLar: could find file %s\n",
                name);
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        return rc;
    }

    sz = sqlite3_column_int(stmt,3);
    data = sqlite3_column_blob(stmt,4);
    data_sz = sqlite3_column_bytes(stmt,4);

    output = calloc(1, sz + 1);
    if(sz != data_sz) {
        out_size = sz;

        rc = uncompress((Bytef*)output,
                        &out_size,
                        (const Bytef*)data,
                        data_sz);
        if(rc != Z_OK) {
            fprintf(stderr,
                    "Error: could not uncompress data\n");
            return SQLITE_ERROR;
        }
    } else {
        memcpy(output, data, sz);
    }

    *size = sz;
    *out = output;
    sqlite3_finalize(stmt);
    return SQLITE_OK;
}


/* adopted from monolith, re-imagined for sndkit */

static int sqlar_loadwav_db(sk_core *core,
                            sqlite3 *db,
                            const char *filename,
                            sk_table **ft)
{
    char *buf;
    int sz;
    sk_drwav wav;
    size_t size;
    SKFLT *tbl;
    sk_table *ftp;
    int rc;

    sz = 0;
    buf = NULL;
    rc = sqlar_extract_to_buffer_db(db, filename, &buf, &sz);

    if (rc != SQLITE_OK) {
        if (buf != NULL) free(buf);
        fprintf(stderr, "SQLite problems\n");
        return 1;
    }

    if (!sk_drwav_init_memory(&wav, buf, sz, NULL)) {
        fprintf(stderr, "drwav could not initialize\n");
        free(buf);
        return 2;
    }

    size = wav.totalPCMFrameCount;
    sk_core_table_new(core, size);
    sk_core_table_pop(core, ft);
    ftp = *ft;
    tbl = sk_table_data(ftp);
    sk_drwav_read_pcm_frames_f32(&wav, size, tbl);
    sk_drwav_uninit(&wav);
    free(buf);
    return 0;
}

static int cratewav(sk_core *core, const char *idstr)
{
    int rc;
    sqlite3 *db;
    sk_table *ft;
    sqlite3_stmt *stmt;
    const char *filename;
    int count;
    char *ergo;

    db = smp_db();

    if (db == NULL) return 1;

    sqlite3_prepare_v2(db,
                       "SELECT value, COUNT(DISTINCT uuid) "
                       "from wikizet "
                       "WHERE uuid LIKE ?1 || \"%\" "
                       "AND value LIKE \"/%\";",
                       -1, &stmt, NULL);

    ergo = NULL;
    if (idstr[0] == 'g') {
        size_t sz;
        /* 'g' is truncated, so N - 1 */
        sz = strlen(idstr) - 1;
        ergo = malloc(sz + 1);
        ergo[sz] = '\0';
        ergo_to_hex(&idstr[1], sz, ergo);

        sqlite3_bind_text(stmt, 1, ergo, -1, NULL);
    } else {
        sqlite3_bind_text(stmt, 1, idstr, -1, NULL);
    }

    rc = sqlite3_step(stmt);

    if (rc != SQLITE_ROW) {
        fprintf(stderr, "cratewav: %s\n", sqlite3_errmsg(db));
        sqlite3_finalize(stmt);
        return 1;
    }

    count = sqlite3_column_int(stmt, 1);

    if (count < 1) {
        fprintf(stderr, "Could not resolve id %s\n", idstr);
        sqlite3_finalize(stmt);
        return 2;
    } else if (count > 1) {
        fprintf(stderr, "id pattern %s not unique.\n", idstr);
        sqlite3_finalize(stmt);
        return 3;
    }

    filename = (const char *)sqlite3_column_text(stmt, 0);

    rc = sqlar_loadwav_db(core, db, &filename[1], &ft);

    if (rc) {
        fprintf(stderr, "There were SQLar problems.\n");
        sqlite3_finalize(stmt);
        return 4;
    }

    sqlite3_finalize(stmt);

    if (ergo != NULL) free(ergo);

    sk_core_table_push(core, ft);
    return 0;
}

static lil_value_t l_cratewav(lil_t lil,
                              size_t argc,
                              lil_value_t *argv)
{
    sk_core *core;
    int rc;

    core = lil_get_data(lil);

    SKLIL_ARITY_CHECK(lil, "cratewave", argc, 1);

    rc = cratewav(core, lil_to_string(argv[0]));

    SKLIL_ERROR_CHECK(lil, rc, "cratewav didn't work out.");

    return NULL;
}

static lil_value_t opendb(lil_t lil, size_t argc, lil_value_t *argv)
{
    if (argc == 0) {
        smp_open_db("a.db");
    } else {
        smp_open_db(lil_to_string(argv[0]));
    }

    return NULL;
}

void load_smp(lil_t lil)
{
    lil_register(lil, "opendb", opendb);
    lil_register(lil, "cratewav", l_cratewav);
}
