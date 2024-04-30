# Odoo S3 Backup

`odoo-s3-backup` is a simple Docker service to create a complete backup (DB and filestore) of any Odoo v17 plateform using the native function instead of using a plugin inside.

It sends a `POST` query to the endpoint concerned. The main benefit is to launch backups from outside the platform to prevent missed executions.

After creating the zip archive, it is sent to an S3 compatible bucket.

## Environment variables

### Required ones
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET
ODOO_URL
ODOO_DB
ODOO_MASTER_PWD
```

Optional ones
```
S3_ENDPOINT
TZ # timezone, e.g. Europe/Paris 
```

## Execution

Build and run it like a common Docker service
````
docker run \
-e \
-e "AWS_ACCESS_KEY_ID=xxx" \
-e "AWS_SECRET_ACCESS_KEY=xxx" \
-e "S3_BUCKET=xxx" \
-e "ODOO_URL=https://odoo.xxx.com" \
-e "ODOO_DB=xxx" \
-e "ODOO_MASTER_PWD=xxx" \
-it odoo-s3-backup
```