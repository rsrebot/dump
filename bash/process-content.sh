jq 'select(.widgets!=null) | .widgets[] | select(.properties!=null)  | .properties | to_entries[] | select(.value|tostring|test("^/api"))' muralcontent.json |sed -ne 's#.*/assets/##p'| sed -e 's#/.*##' | sort -u > ws.txt