# This file is manually maintained.
(import aw_2010_wav32/import :as aw)
(import sh1wf/import :as sh1wf)
(import kawaiwf/import :as kawaiwf)
(import vintage_drums/import :as vintage_drums)

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
(ww-add-link "wttest" "wttest.org")
(ww-add-link "brainstorm" "brainstorm.org")
(ww-add-link "wiki_index" "wiki_index.org")
(ww-add-link "labels" "labels.org")

(aw/import)
(sh1wf/import)
(kawaiwf/import)
(vintage_drums/import)

(ww-sync)
(ww-close)
