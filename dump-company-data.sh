set -e # stop running scrip on error

read -p "Company to dump: " company

read -p "Workspace list [ws.txt]: " wsfile
wsfile=${wsfile:-ws.txt}

read -p "Mongo host name and port [localhost:27017]: " source_host
source_host=${source_host:-localhost}

read -p "Mongo user [admin]: " source_user
source_user=${source_user:-admin}

read -p "Mongo password: " source_pass

read -p "Mongo auth db [admin]: " source_auth_db
source_auth_db=${source_auth_db:-admin}

read -p "Mongo db: " source_db

read -p "Split murals in chuck of [200]: " murals_chunk
murals_chunk=${murals_chunk:-200}

read -p "Split profiles in chuck of [200]: " profiles_chunk
profiles_chunk=${profiles_chunk:-200}

read -p "Output dir [./$company]" output
output=${output:-$company}

echo
echo  
echo "Starting dump for company: $company"
echo "   from db => host: $source_host, db: $source_db to $output"
echo 

# workspaces
workspaces=$(cat $wsfile | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
echo Dumping Workspaces ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/dump
echo Exporting Workspaces ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "username,membersIndex" --out ./tempws.json
echo Exported Workspaces: $workspaces
echo

# rooms
echo Dumping Rooms ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c rooms --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/dump
echo Exporting Rooms Ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c rooms --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "_id" --out ./temproom.json
echo Rooms exported
echo

# murals
echo Dumping Murals ...
time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c muralcontents --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/dump
echo Exporting Murals Ids ...
time mongoexport --host $source_host -u $source_user -p $source_pass -vvvvv -c muralcontents --query "{ ownerId: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --type json --sslAllowInvalidCertificates --ssl --fields "id" --out ./tempmural.json
echo Murals Exported
echo

# pending invitations
echo Dumping PendingInvitations ...
mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c pendinginvitations --query "{ workspace: {\$in: $workspaces }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/dump
echo PendingInvitations exported
echo

# profiles
cat tempws.json | jq -r '.membersIndex[]' | split -l $profiles_chunk
total=$(ls x* | wc -l)
echo
echo "Processing $total profiles in chunks of $profiles_chunk profiles"

i=0
for f in x*
do 
  profiles=$(cat $f | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
  echo "Processing profiles [$i/$total] ..."

  echo Dumping Profiles ...
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c profiles --query "{ username: {\$in: $profiles }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/profile_$i
  echo Exported Profiles
  echo
  ((i=i+1))
done
rm -rf x*
echo Done processing Profiles
echo

# activity, chats
cat tempmural.json | jq -r '.id' | split -l $murals_chunk

total=$(ls x* | wc -l)
echo
echo "Processing $total murals in chunks of $murals_chunk murals to get activity and chats"

i=0
for f in x*
do 
  murals=$(cat $f | jq -R -s -c 'split("\n")' | jq -c '.[:-1]' | sed "s/\"/'/g")
  echo "Processing rooms to export activity [$i/$total] ..."

  echo Dumping Activity ...
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c activitySummary --query "{ mural: {\$in: $murals }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/activity_$i
  echo Exported Activity
  echo Dumping Chats
  time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c chats --query "{ mural: {\$in: $murals }}" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out $output/chat_$i
  echo Exported Chats
  echo
  ((i=i+1))
done
rm -rf x*
echo Done exporting activity and chats
echo

echo
echo "Done exporting data for company $company"