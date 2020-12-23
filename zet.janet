(defn html-escape (str)
  # make sure mentions appear
  (string/replace-all
   "@<" "@&lt;"
   (string/replace-all "txt>" "txt&gt;" str)))

(def valid-pgname
  '{:letter (range "az" "AZ")
    :number (range "09")
    :word (any (choice :letter (set "_") :number))
    :everything (any (choice 1))
    :main (sequence (capture :word) (capture :everything))})

(defn mklink [word]
  (def name (peg/match valid-pgname (string/slice word 1 -1)))
  (string "(" (refstr (name 0)) ")" (name 1)))

(defn fmtmsg [msg]
  (var words (string/split " " (html-escape msg)))
  (for w 0 (length words)
    (if (= ((words w) 0) ((string/bytes "!") 0))
      (set (words w)
           (mklink (words w)))))
  (string/join words " "))
(defn print-value [uuid]
  (def vals
    (sqlite3/eval
     (ww-db)
     (string "SELECT time, value, "
             "strftime('%s', time) as secs from wikizet "
             "WHERE UUID is \"" uuid
             "\" AND value like \">%\""
             "ORDER by secs DESC;")))

  (each v vals
    (org (string (v "time") ":\n\n"))
    (org (string (string/slice (v "value") 1 -1) "\n\n"))))

(defn refstr [uuid]
  (def query (sqlite3/eval
          (ww-db)
          (string
           "SELECT value FROM wikizet WHERE "
           "UUID IS '" uuid "' AND value LIKE '#%';")))

  (var str @[])
  (each v query
    (array/push str (string/slice (v "value") 1 9)))

  (string/join str ", "))

(defn messages [group &opt typeflag]
  (default typeflag "@")
  (def gid
       (((sqlite3/eval
        (ww-db)
        (string
         "SELECT UUID FROM wikizet where "
         "value is \"" typeflag group "\";")) 0) "UUID"))

  (def addr
    (sqlite3/eval
     (ww-db)
     (string
      "SELECT strftime('%Y-%m-%d-%H-%M', time, 'localtime') as time, value, uuid from wikizet where UUID IN ("
      "SELECT UUID from wikizet WHERE value is '#"
      gid "') and VALUE like '>%' ORDER by strftime('%s', time) DESC;")))

  (each id addr
    (org (string "*"
                 (string
                  "[" (string/slice (id "UUID") 0 8) "] ")
                 (id "time")
                 "*: "))
    (org (string
          (fmtmsg (string/slice (id "value") 1 -1))
          "\n\n"))
    (org (string "references: " (refstr (id "UUID")) "\n\n"))))

(defn page-updates [] (messages (ww-name) "!"))
