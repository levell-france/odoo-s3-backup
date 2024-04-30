#!/bin/sh

# Check the mandatory environment variables
if [ -z "$ODOO_URL" ] || [ -z "$ODOO_DB" ] || [ -z "$ODOO_MASTER_PWD" ] || [ -z "$S3_BUCKET" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "The environment variables ODOO_URL, ODOO_DB, ODOO_MASTER_PWD, S3_BUCKET, AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are mandatory!"
    exit 1
fi

# Create a temporary file to get archive
response_file=$(mktemp)

# Make the POST request to the Odoo backup endpoint
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "master_pwd=$ODOO_MASTER_PWD&name=$ODOO_DB&backup_format=zip" -o "$response_file" "$ODOO_URL/web/database/backup"

if [ $? -eq 0 ]; then
    filename="$(date +%Y-%m-%d-%H-%M-%S).zip"
    # Upload the archive to the S3 bucket
    mc alias set s3 "$S3_ENDPOINT" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" --api S3v4
    mc cp "$response_file" "s3/$S3_BUCKET/$filename"
    if [ $? -eq 0 ]; then
        echo "Archive successfully uploaded to S3 bucket"
    else
        echo "Error sending archive to S3"
    fi
else
    echo "Backup endpoint query failed"
fi

# Remove temporary file
rm "$response_file"
