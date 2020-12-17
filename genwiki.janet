# This file is manually maintained.

(ww-open "a.db")
(print "Clearing the database.")
(ww-clear)

(ww-add-link "index" "index.org")
(ww-add-link "akwf" "akwf/akwf.org")

(ww-sync)
(ww-close)
