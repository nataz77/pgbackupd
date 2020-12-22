#!/bin/bash
# shellcheck shell=bash

function dump {
    echo "Beginning pg_dump"
    if [ ! -z "$DEBUG" ]
    then
        pg_dump -h "$HOST" -U "$USER" -v > "$OUTPUTDIR"/"$1".sql  2>&1
    else
        pg_dump -h "$HOST" -U "$USER" > "$OUTPUTDIR"/"$1".sql  2>&1
    fi
    
    if [ ! -z "$AZCOPY" ]
    then
        azupload
    fi
    
    if [ ! -z "$S3COPY" ]
    then
        s3upload
    fi
}

function dumpall {
    echo "Beginning pg_dumpall"
    # Redirecting STDERR to STDOUT because pg_dump outputs detailed object comments, start/stop times to the dump file, and progress messages to STDERR
    # The same applies to pg_dump in function dump
    if [ ! -z "$DEBUG" ]
    then
        pg_dumpall -h "$HOST" -U "$USER" -v > "$OUTPUTDIR"/"$1".sql 2>&1
    else
        pg_dumpall -h "$HOST" -U "$USER" > "$OUTPUTDIR"/"$1".sql 2>&1
    fi
    
    if [ ! -z "$AZCOPY" ]
    then
        azupload
    fi
    
    if [ ! -z "$S3COPY" ]
    then
        s3upload
    fi
}

function azupload {
    echo "Uploading to Azure enabled. Starting blob upload"
    az storage azcopy blob upload -c "$AZ_CONTAINER_NAME" --account-name "$AZ_ACCOUNT_NAME" -s "$OUTPUTDIR"/"$date".sql --auth-mode key
    if [ $? -eq 0 ]
    then
        echo "Upload completed"
    else
        echo "Unable to upload to Azure, please check the az command output above for more details"
    fi
}

function s3upload {
    if bucket_exists "$S3_BUCKET_NAME"
    then
        aws s3 cp "$OUTPUTDIR"/"$date".sql s3://"$S3_BUCKET_NAME"
    else
        aws s3 mb s3://"$S3_BUCKET_NAME"
        aws s3 cp "$OUTPUTDIR"/"$date".sql s3://"$S3_BUCKET_NAME"
    fi
    
    if [ $? -eq 0 ]
    then
        echo "Upload to S3 completed"
    else
        echo "Unable to upload to S3, please check the aws command output above for more details"
    fi
}

function bucket_exists {
    bucketname=$1
    if ! aws s3api head-bucket --bucket "$bucketname" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

function outputfolder_readable {
    if [ ! -r "$OUTPUTDIR" ]
    then
        echo "$OUTPUTDIR is not readable";
        # Sending an exit code != 0
        exit 2;
    fi
}

set -e 
echo "Script starting @ $(date)"
outputfolder_readable
if [ ! -z "$PASSWORD" ] && [ ! -z "$DATABASE" ]
then
    echo "$HOST:$PORT:$DATABASE:$USER:$PASSWORD" > /.pgpass
    chmod 600 /.pgpass
    export PGPASSFILE=/.pgpass
fi
date="$(date +"%d%m%Y")"
if [ -z "$FULLDUMP" ]
then
    dump "$date"
else
    dumpall "$date"
fi
echo "Removing older backup files"
find "$OUTPUTDIR"/* -mtime +14 -exec rm -rf {} \;
echo "Script ended @ $(date)"