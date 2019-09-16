#! /bin/bash

. ./config/destination.config

inserters=3 # number of inserters per collection

read -p "Company to dump: " company

input=./$company/global-templates

mongorestore --host $source_host -u $source_user -p $source_pass -vvvvv --authenticationDatabase $source_auth_db --sslAllowInvalidCertificates --ssl --numInsertionWorkersPerCollection $inserters $input

echo DONE