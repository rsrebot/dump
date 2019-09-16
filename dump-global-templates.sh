#! /bin/bash

. ./config/source.config

set -e # stop running scrip on error

read -p "Company to dump: " company

output=$company

time mongodump --host $source_host -u $source_user -p $source_pass -vvvvv -c templates --query "{ global: true }" --authenticationDatabase $source_auth_db --db $source_db --sslAllowInvalidCertificates --ssl --out ./$output/global-templates

echo DONE