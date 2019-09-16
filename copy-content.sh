set -e

read -p "Source container url: " source_url

read -p "Source SaS: " source_sas

read -p "Destination container url: " dest_url

read -p "Destination SaS: " dest_sas

read -p "Files with workspaces: " wsfile


total=$(cat $wsfile | wc -l)
echo
echo "Copying $total workspaces ..."

i=1
while read p; do
  echo "Copying workspace $p [$i/$total]"
  azcopy copy "$source_url/$p/?$source_sas" "$dest_url/?$dest_sas" --recursive
  echo "Workspace $p done."
  echo
  ((i=i+1))
done <$wsfile

echo done