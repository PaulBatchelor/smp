(def page-prefix "aw_")
(def path "aw_2010_wav32")
(def pages
  @["add"
    "am"
    "classic"
    "fm"
    "formants"
    "fractal"
    "hm"
    "index"
    "misc"
    "modulo"
    "partials"
    "phaseshift"
    "process"
    "series"
    "spectral"
    "uhf"
    "xy"
    "stats"
   ])

(defn mkpage [p]
  (if (= p "index")
    "aw_2010_wav32"
    (string page-prefix p)))

(defn import []
  (each p pages (ww-add-link
                 (if (= p "index")
                   "aw_2010_wav32"
                   (string page-prefix p))
                 (string path "/" p ".org"))))

