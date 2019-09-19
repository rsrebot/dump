jq 'select(.widgets!=null) | .widgets[] | select(.properties!=null)  | .properties | to_entries[] | select(.value|tostring|test("^/api"))' muralcontent.json | sed -ne 's#.*/assets/##p' | sed 's/,$//' | sort -u > assets.txt
cat assets.txt | sed -e 's#/.*##' | sort -u > ws1.txt
diff --new-line-format="" --unchanged-line-format="" <(sort ws1.txt) <(sort ws.txt) > diff.txt
while read line; do grep -wF "$line" assets.txt; done < diff.txt | tee extra-assets.txt
