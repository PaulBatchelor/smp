function zetit() {
    echo "importing $1"
    weewiki zet import < $1/zet.tsv
}

weewiki janet genwiki.janet

zetit akwf
zetit aw_2010_wav32
zetit waveedit

weewiki vacuum
