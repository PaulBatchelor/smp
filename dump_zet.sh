
function zetout() {
    echo "dumping $1"
    weewiki zet export $1.sqlar > $1/zet.tsv
}

zetout akwf
zetout aw_2010_wav32
zetout waveedit

echo "dumping logs group"
weewiki zet export logs > logs.tsv
