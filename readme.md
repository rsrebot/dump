# Company Data Migration to Tenant

## Export Data

### Get company workspaces to export

- Update `./bash/config/source.config` with the mongodb connection information to the prod DB (it will use the secondary)
- Get list of company workspaces. (Currently we can't trust the company field in workspaces (profiles))
  - `node index.js "companyid"` (This should take around 30 min for a company with 30k Murals)
    It will output a file: `./bash/ws.txt` these are the workspaces to export from mongo
  - `cd bash`
  - `./dump-mural-content.sh` (This should take around 10 mins for 30K murals)
    It will take a while and generate `muralcontent.json`
  - `./process-content.sh`
    This will run for some minutes and output: `./bash/extra-assets.txt` these are the assets to copy from Azure (uploads) and `./bash/thumbnails.txt` these are thumbnails to copy from azure.

### Mongo

- `./dump-company-data.sh` to export all the company data (This should take around 7 hours for a company like Fidelity - 30K Murals)
- `./dump-global-templates.sh` to export all global templates (This should take a few seconds)

## Restore Data into the tenant DB

### Azure

- TODO: run azure export instructions (use ws-azure.txt as input)

### Mongo

- Update `./bash/config/destination.config` with the mongodb connection information to the Tenant DB.
- `./restore-company-data.sh` (This should take around 40 min for a company with around 30K murals) <br/>
- `./restore-company-activity.sh` (This should take around 1.5 hours)
- `./restore-templates.sh` (This should take a few seconds) <br/>
