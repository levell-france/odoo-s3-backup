
#!/bin/sh
set -eu

# Check required environment variables
for var in ODOO_URL ODOO_DB ODOO_MASTER_PWD \
           S3_ENDPOINT S3_BUCKET \
           AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
do
    eval "value=\${$var:-}"
    if [ -z "$value" ]; then
        echo "ERROR: Missing environment variable: $var" >&2
        exit 1
    fi
done

# Create a temporary file for the backup archive
response_file=$(mktemp)

# Ensure the temporary file is removed on exit
trap 'rm -f "$response_file"' EXIT
trap 'exit 1' HUP INT TERM

echo "Starting Odoo backup..."

# Download the Odoo database backup
curl --fail --silent --show-error \
    --connect-timeout 30 \
    --max-time 1800 \
    --retry 3 \
    --data-urlencode "master_pwd=$ODOO_MASTER_PWD" \
    --data-urlencode "name=$ODOO_DB" \
    --data-urlencode "backup_format=zip" \
    --output "$response_file" \
    "${ODOO_URL%/}/web/database/backup"

# Verify the integrity of the ZIP archive
if ! unzip -tqq "$response_file"; then
    echo "ERROR: Invalid backup ZIP archive" >&2
    exit 1
fi

# Generate a timestamped backup filename (UTC)
filename="$(date -u +%Y-%m-%d-%H-%M-%S).zip"

# Configure the S3 connection
mc alias set s3 \
    "$S3_ENDPOINT" \
    "$AWS_ACCESS_KEY_ID" \
    "$AWS_SECRET_ACCESS_KEY" \
    --api S3v4

# Upload the backup archive to the S3 bucket
echo "Uploading backup to S3..."

mc cp "$response_file" "s3/$S3_BUCKET/$filename"

echo "SUCCESS: Backup uploaded to s3/$S3_BUCKET/$filename"
