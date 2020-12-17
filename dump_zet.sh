if [ a.db -nt zet.tsv ]
then
    echo "dumping zet"
    weewiki zet export > zet.tsv
fi
