set -e

echo Getting workspaces IDs fro $1
time node ./index.js $1
echo Done.

time ./bash/dump-company-data.sh

time ./bash/dump-global-templates.sh

time ./bash/dump-mural-contents.sh

time ./bash/process-content.sh

echo Done dumping data for $1
