set -e

echo Restoring data

time ./bash/restore-templates.sh

time ./bash/restore-company-data.sh

time ./bash/restore-company-activity.sh

echo DONE