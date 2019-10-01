#! /bin/bash

. ../config/destination.config

inserters=3 # number of inserters per collection

input=$input_dir/global-templates/$source_db

mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --db $dest_db --numInsertionWorkersPerCollection $inserters $input

echo DONE