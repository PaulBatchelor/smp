(defn stats [group n]
  (def group-uuid (ww-zet-resolve (string "@" group)))


(sqlite3/eval (ww-db) (string/format ``
CREATE TEMPORARY VIEW gtab AS SELECT UUID FROM
wikizet where UUID in (SELECT UUID from wikizet
WHERE value IS "#" || '%s');
`` group-uuid))

  (def q (sqlite3/eval (ww-db)
(string/format ``

SELECT fname, cratefiles.id,
group_concat(timefmt, '::') as msgtimes,
group_concat(msg, '::') as msg
FROM
(SELECT
time,
strftime('%%Y-%%m-%%d-%%H-%%M', time, 'localtime') as timefmt,
msgtab.id as msgid, msg, link FROM
   (SELECT time, UUID AS id, value AS msg FROM
        wikizet WHERE UUID in gtab AND value like ">%%"
) msgtab
INNER JOIN (SELECT UUID AS id, substr(value, 2) AS link FROM wikizet
WHERE value LIKE "#%%" and UUID in gtab
) linktab
ON msgtab.id = linktab.id) loglinks

INNER JOIN

(SELECT UUID AS id, value AS fname from wikizet
    WHERE UUID in gtab
    AND value LIKE "/%%"

) cratefiles

ON cratefiles.id = loglinks.link

GROUP BY fname
ORDER BY strftime("%%s", loglinks.time) DESC

LIMIT %d;
`` n)

))

(sqlite3/eval (ww-db) "DROP VIEW gtab")

(each val q
  (org (string
        "** "
        "g" (ergo/hex-to-ergo (string/slice (val "id") 0 8))
        "\n"))
  (org (string "*Filename:*"))
  (print (string " " (val "fname")))
  (org "\n")
  (def msgs (string/split "::" (val "msg")))
  (def time (string/split "::" (val "msgtimes")))
  (for i 0 (length msgs)
    (org (string "["(time i) "] "(string/slice (msgs i) 1) "\n\n")))
))
