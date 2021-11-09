(def page-prefix "vintage_drums_")
(def path "vintage_drums")
(def pages @["index" "stats"])

(defn import []
  (each p pages (ww-add-link
                 (if (= p "index")
                   path
                   (string page-prefix p))
                 (string path "/" p ".org"))))
