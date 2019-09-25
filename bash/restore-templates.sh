#! /bin/bash

. ./config/destination.config

inserters=3 # number of inserters per collection

read -p "Company to dump: " company

input=./$company/global-templates/$source_db

mongorestore --host $dest_host -u $dest_user -p $dest_pass -vvvvv --authenticationDatabase $dest_auth_db --sslAllowInvalidCertificates --ssl --db $dest_db --numInsertionWorkersPerCollection $inserters $input

echo DONE