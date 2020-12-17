weewiki janet genwiki.janet
echo "importing akwf"
weewiki zet import < akwf/zet.tsv
echo "importing aw_2010_wav32"
weewiki zet import < aw_2010_wav32/zet.tsv
weewiki vacuum
