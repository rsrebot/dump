#! /bin/bash

. ./config/destination.config

set -e # stop running scrip on error

read -p "Company to dump: " company

inserters=3 # number of inserters per collection

input=./$company

# Workspaces, Rooms, Murals, PendingInivtations
echo Restoring Workspaces, Rooms, Murals and Pending Invitations ...
mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db dest_db $input/dump
echo Done restoring Workspaces, Rooms, Murals and Pending Invitations 
echo

# Profiles
total=$(ls $input/profile* | wc -l)
echo
echo "Restoring $total profile chunks ..."

i=0
for f in $input/profile*
do 
  echo "Restoring profile chunck [$i/$total] ..."
  mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db dest_db  $f 
  echo Profile restored
  ((i=i+1))
done
echo Done restoring Profiles
echo

# Activity
total=$(ls $input/activity* | wc -l)
echo
echo "Restoring $total activity chunks ..."

i=0
for f in $input/activity*
do 
  echo "Restoring activity chunck [$i/$total] ..."
  mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db dest_db $f
  echo Activity restored
  ((i=i+1))
done
echo Done restoring Activity
echo

# Chats
total=$(ls $input/chat* | wc -l)
echo
echo "Restoring $total chats chunks ..."

i=0
for f in $input/chat*
do 
  echo "Restoring chat chunck [$i/$total] ..."
  mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db dest_db $f
  echo Chat restored
  ((i=i+1))
done
echo Done restoring Chat

echo "Restore for company $company finished"