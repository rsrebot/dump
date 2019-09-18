# Company Data Migration to Tenant

## Export Data

### Get company workspaces to export

- Update `./bash/config/source.config` with the mongodb connection information to the prod DB (it will use the secondary)
- Get list of company workspaces. (Currently we can't trust the company field in workspaces (profiles))
  - `node index.js "companyid"`
    It will output a file: `./bash/ws.txt` these are the workspaces to export from mongo
  - `cd bash`
  - `./dump-mural-content.sh`
    It will take a while and generate `muralcontent.json`
  - `./process-content.sh`
    This will run for some minutes and output: `./bash/ws-azure.txt` these are the workspaces to export from Azure

### Mongo

- `./dump-company-data.sh` to export all the company data (it might take several hours)
- `./dump-global-templates.sh` to export all global templates (this should be fast)

## Restore Data into the tenant DB

### Azure

- TODO: run azure export instructions (use ws-azure.txt as input)

### Mongo

- Update `./bash/config/destination.config` with the mongodb connection information to the Tenant DB.
- `./restore-company.sh` <br/>`:exclamation: This script will delete the data in the destination db before restoring.`
- `./restore-templates.sh` <br/>`:exclamation: This script will delete the data in the destination db before restoring.`
