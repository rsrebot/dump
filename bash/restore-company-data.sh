#! /bin/bash

. ../config/destination.config

set -e # stop running scrip on error

inserters=3 # number of inserters per collection

input=$input_dir

# Workspaces, Rooms, Murals, PendingInivtations
echo Restoring Workspaces, Rooms, Murals and Pending Invitations ...
mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db $dest_db $input/dump/$source_db
echo Done restoring Workspaces, Rooms, Murals and Pending Invitations 
echo

# Profiles
total=$(ls $input/profiles/profile* | grep 'profile' | wc -l)
echo
echo "Restoring $total profile chunks ..."

i=0
for f in $input/profiles/profile*
do 
  echo "Restoring profile chunck [$i/$total] ..."
  mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters --db $dest_db  $f/$source_db
  echo Profile restored
  ((i=i+1))
done
echo Done restoring Profiles
echo

echo "Restore finished"