function zetit() {
    echo "importing $1"
    weewiki zet import < $1/zet.tsv
}

weewiki janet genwiki.janet

zetit akwf
zetit aw_2010_wav32
zetit waveedit
zetit piezo
zetit unfa
zetit sh1wf
zetit kawaiwf
zetit vengeance
zetit vintage_drums
zetit soundfonts
zetit pswt
zetit shapes

echo "importing logs"
weewiki zet import < logs.tsv
echo "importing labels"
weewiki zet import < labels.tsv

echo "vacuuming"
weewiki vacuum
