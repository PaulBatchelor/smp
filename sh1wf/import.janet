(def page-prefix "sh1wf_")
(def path "sh1wf")
(def pages @["index"])

(defn import []
  (each p pages (ww-add-link
                 (if (= p "index")
                   path
                   (string page-prefix p))
                 (string path "/" p ".org"))))
