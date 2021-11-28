(def page-prefix "shapes_")
(def path "shapes")
(def pages @["index"])

(defn mkpage [p]
  (if (= p "index")
    "shapes"
    (string page-prefix p)))

(defn import []
  (each p pages (ww-add-link
                 (if (= p "index")
                   "shapes"
                   (string page-prefix p))
                 (string path "/" p ".org"))))

