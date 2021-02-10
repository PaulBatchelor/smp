# This file is manually maintained.
(import aw_2010_wav32/import :as aw)
(import sh1wf/import :as sh1wf)
(import kawaiwf/import :as kawaiwf)

(ww-open "a.db")
(print "Clearing the database.")
(ww-clear)

(ww-add-link "index" "index.org")
(ww-add-link "usage" "usage.org")
(ww-add-link "akwf" "akwf/akwf.org")
(ww-add-link "waveedit" "waveedit/waveedit.org")
(ww-add-link "piezo" "piezo/piezo.org")
(ww-add-link "logs" "logs.org")
(ww-add-link "unfa" "unfa/unfa.org")

(aw/import)
(sh1wf/import)
(kawaiwf/import)

(ww-sync)
(ww-close)
