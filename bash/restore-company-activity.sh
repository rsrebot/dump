#! /bin/bash

. ./config/destination.config

set -e # stop running scrip on error

inserters=3 # number of inserters per collection

input=./$company

# Activity
total=$(ls $input/activity* | grep 'activity' | wc -l)
echo
echo "Restoring $total activity chunks ..."

i=0
for f in $input/activity*
do 
  echo "Restoring activity chunck [$i/$total] ..."
  for h in 1 2 3; 
  do
    mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db $dest_db $f/$source_db && break || sleep 5;
  done
  echo Activity restored
  ((i=i+1))
done
echo Done restoring Activity
echo

# Chats
total=$(ls $input/chat* | grep 'chat' | wc -l)
echo
echo "Restoring $total chats chunks ..."

i=0
for f in $input/chat*
do 
  echo "Restoring chat chunck [$i/$total] ..."
  mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db $dest_db $f/$source_db
  echo Chat restored
  ((i=i+1))
done
echo Done restoring Chat

echo "Restore for company $company finished"