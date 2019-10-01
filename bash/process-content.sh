jq 'select(.widgets!=null) | .widgets[] | select(.properties!=null)  | .properties | to_entries[] | select(.value|tostring|test("^/api"))' muralcontent.json | sed -ne 's#.*/assets/##p' | sed 's/"$//' | sort -u > assets.txt
cat assets.txt | sed -e 's#/.*##' | sort -u > ws1.txt
diff --new-line-format="" --unchanged-line-format="" <(sort ws1.txt) <(sort ws.txt) > diff.txt
while read line; do grep -wF "$line" assetsx.txt; done < diff.txt | tee extra-assets.txt

#Thumbnails
grep -Po  '"https://mural.azureedge.net/thumbnails/.*?"' muralcontent.json | sed 's/"//g' | sed -e 's/https:\/\/mural.azureedge.net\/thumbnails\///g' | sed -e 's/?v.*//g' > thumbs.txt
cat thumbs.txt | sed -e 's#/.*##' | sort -u > ws2.txt

diff --new-line-format="" --unchanged-line-format="" <(sort ws2.txt) <(sort ws.txt) > diff2.txt
while read line; do grep -wF "$line" thumbs.txt; done <  diff2.txt | tee thumbnails.txt

# Avatars
members="$(cat tempws.json | jq -r '.membersIndex[]' | sort -u | tr '\n' '|' | sed 's/|$//')"
grep -v '"type":"organization"' profiles.json | grep -v '$members' | sed -ne 's/.*"avatar":"\([^"?]*\).*/\1/p' | sed -e 's/https:\/\/murally.blob.core.windows.net:443\/uploads\///g' | grep -v 'https:' > avatars.txt

# Remove temp files
# rm ws1.txt ws2.txt diff.txt diff2.txt
# rm temp*