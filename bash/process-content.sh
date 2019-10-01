. ../config/source.config
temp_dir=$out_dir/temp

jq 'select(.widgets!=null) | .widgets[] | select(.properties!=null)  | .properties | to_entries[] | select(.value|tostring|test("^/api"))' $temp_dir/muralcontent.json | sed -ne 's#.*/assets/##p' | sed 's/"$//' | sort -u > $out_dir/assets.txt
cat assets.txt | sed -e 's#/.*##' | sort -u > $temp_dir/ws1.txt
diff --new-line-format="" --unchanged-line-format="" <(sort ws1.txt) <(sort ws.txt) > $temp_dir/diff.txt
while read line; do grep -wF "$line" assetsx.txt; done < $temp_dir/diff.txt | tee $out_dir/extra-assets.txt

#Thumbnails
grep -Po  '"https://mural.azureedge.net/thumbnails/.*?"' $temp_dir/muralcontent.json | sed 's/"//g' | sed -e 's/https:\/\/mural.azureedge.net\/thumbnails\///g' | sed -e 's/?v.*//g' > $temp_dir/thumbs.txt
cat $temp_dir/thumbs.txt | sed -e 's#/.*##' | sort -u > $temp_dir/ws2.txt

diff --new-line-format="" --unchanged-line-format="" <(sort $temp_dir/ws2.txt) <(sort $wsfile) > $temp_dir/diff2.txt
while read line; do grep -wF "$line" $temp_dir/thumbs.txt; done < $temp_dir/diff2.txt | tee $out_dir/thumbnails.txt

# Avatars
members="$(cat $temp_dir/tempws.json | jq -r '.membersIndex[]' | sort -u | tr '\n' '|' | sed 's/|$//')"
grep -v '"type":"organization"' $temp_dir/profiles.json | grep -v '$members' | sed -ne 's/.*"avatar":"\([^"?]*\).*/\1/p' | sed -e 's/https:\/\/murally.blob.core.windows.net:443\/uploads\///g' | grep -v 'https:' > $out_dir/avatars.txt

# Remove temp files
# rm ws1.txt ws2.txt diff.txt diff2.txt
# rm temp*