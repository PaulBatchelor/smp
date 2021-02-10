(def page-prefix "kawaiwf_")
(def path "kawaiwf")
(def pages @["index"])

(defn import []
  (each p pages (ww-add-link
                 (if (= p "index")
                   path
                   (string page-prefix p))
                 (string path "/" p ".org"))))
