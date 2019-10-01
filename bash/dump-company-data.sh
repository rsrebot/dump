#! /bin/bash

# Dumps Workspaces, Rooms, Murals, Users, Activity, PendingInvitations and Chats for a given Company.

. ../config/source.config

set -e # stop running scrip on error

output=$out_dir
mkdir -p $out_dir/temp
temp_dir=$out_dir/temp

echo
echo  
echo "Starting dump"
echo "   from db => host: $source_host, db: $source_db to $output"
echo 

# workspaces
workspaces=$(cat $wsfile | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
echo Dumping Workspaces ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/dump
echo Exporting Workspaces ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "username,membersIndex" --readPreference "{mode: 'secondary'}" --out $temp_dir/tempws.json
echo Exported Workspaces: $workspaces
echo

# rooms
echo Dumping Rooms ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c rooms --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/dump
echo Exporting Rooms Ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c rooms --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "_id" --readPreference "{mode: 'secondary'}" --out $temp_dir/temproom.json
echo Rooms exported
echo

# murals
echo Dumping Murals ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c muralcontents --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/dump
echo Exporting Murals Ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c muralcontents --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "id" --readPreference "{mode: 'secondary'}" --out temp_dir/tempmural.json
echo Murals Exported
echo

# pending invitations
echo Dumping PendingInvitations ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c pendinginvitations --query "{ workspace: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/dump
echo PendingInvitations exported
echo

# profiles
cat $temp_dir/tempws.json | jq -r '.membersIndex[]' | sort -u | split -l $profiles_chunk
total=$(ls x* | wc -l)
echo
echo "Processing $total profiles in chunks of $profiles_chunk profiles"
mkdir -p $output/profiles

i=0
for f in x*
do 
  profiles=$(cat $f | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
  echo "Processing profiles [$i/$total] ..."

  echo Dumping Profiles ...
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $profiles }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/profiles/profile_$i
  echo Exported Profiles
  echo
  ((i=i+1))
done
rm -rf x*
echo Done processing Profiles
echo

# activity, chats
cat $temp_dir/tempmural.json | jq -r '.id' | split -l $murals_chunk

total=$(ls x* | wc -l)
echo
echo "Processing $total murals in chunks of $murals_chunk murals to get activity and chats"
mkdir -p $output/activity
mkdir -p $output/chats

i=0
for f in x*
do 
  murals=$(cat $f | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
  echo "Processing rooms to export activity [$i/$total] ..."

  echo Dumping Activity ...
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c activitySummary --query "{ mural: {\$in: $murals }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/activity/activity_$i
  echo Exported Activity
  echo Dumping Chats
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c chats --query "{ mural: {\$in: $murals }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --readPreference "{mode: 'secondary'}" --out $output/chats/chat_$i
  echo Exported Chats
  echo
  ((i=i+1))
done
rm -rf x*
echo Done exporting activity and chats
echo

echo
echo "Done exporting data"