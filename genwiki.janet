# This file is manually maintained.
(import aw_2010_wav32/import :as aw)

(ww-open "a.db")
(print "Clearing the database.")
(ww-clear)

(ww-add-link "index" "index.org")
(ww-add-link "akwf" "akwf/akwf.org")
(ww-add-link "waveedit" "waveedit/waveedit.org")
(ww-add-link "piezo" "piezo/piezo.org")

# Architecture Waveforms
(aw/import)

(ww-sync)
(ww-close)
