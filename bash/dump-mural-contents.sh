#! /bin/bash

. ../config/source.config

set -e # stop running scrip on error

mkdir -p $out_dir/temp
temp_dir=$out_dir/temp

workspaces=$(cat $wsfile | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")

time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c muralcontents --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $temp_dir/muralcontent.json

time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles  --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl  --out $temp_dir/profiles.json

echo DONE