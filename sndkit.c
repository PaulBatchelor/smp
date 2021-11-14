#include <stdio.h>
#include <sndkit/patchwerk.h>
#include <sndkit/core.h>
#include <sndkit/lil.h>
#include <sndkit/sklil.h>
#include <sqlite3.h>

void sklil_loader_withextra(lil_t lil);
void load_smp(lil_t lil);

static void load(lil_t lil)
{
    sklil_loader_withextra(lil);
    load_smp(lil);
}

static sqlite3 *g_db = NULL;

void smp_open_db(const char *filename)
{
    int rc;
    rc = sqlite3_open(filename, &g_db);

    if (rc) {
        printf("problems opening %s\n", filename);
    }
}

sqlite3 * smp_db(void)
{
    return g_db;
}

static void clean(lil_t lil)
{
    sklil_clean(lil);

    if (g_db != NULL) {
        sqlite3_close(g_db);
        g_db = NULL;
    }
}

int main(int argc, char *argv[])
{
    return lil_main(argc, argv, load, clean);
}
