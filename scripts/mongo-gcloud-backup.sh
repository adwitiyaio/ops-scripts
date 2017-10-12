#!/usr/bin/env bash

echo "Backing up my app's database"

# Path to boto config file, needed by gsutils
BOTO_CONFIG="/etc/boto.cfg"

# Path in which to create the backup (will get cleaned later)
BACKUP_PATH="/var/backups/myapp"

# DB name
DB_NAME="mydb"
USERNAME="my_username"
PASSWORD="my_password"

# Google Cloud Storage Bucket Name
BUCKET_NAME="my_backup_bucket_name"

CURRENT_DATE=`date +"%Y%m%d-%H%M"`

# Backup filename
BACKUP_FILENAME="$DB_NAME_$CURRENT_DATE.tar.gz"

# Create the backup
mongodump --db $DB_NAME --username $USERNAME --password $PASSWORD -o $BACKUP_PATH
cd $BACKUP_PATH

# Archive and compress
tar -cvzf $BACKUP_PATH$BACKUP_FILENAME *

# Copy to Google Cloud Storage
echo "Copying $BACKUP_PATH$BACKUP_FILENAME to gs://$BUCKET_NAME/"

# Below command sets the lifecycle of an object based on the configuration in the corresponding json config file
# We only need to run the below command once
#/usr/bin/gsutil lifecycle set ./gcloud-lifecycle.json gs://$BUCKET_NAME

# Copies the archived backup to google cloud storage
/usr/bin/gsutil cp $BACKUP_PATH$BACKUP_FILENAME gs://$BUCKET_NAME/ 2>&1

# Post clean up
echo "Copying finished"
echo "Removing backup data"
rm -rf $BACKUP_PATH*
