# Info
This repo contains a Kubernetes cronjob that backups a target PostgreSQL instance, uploads a copy of the backup to a Storage Account in Azure or a AWS S3 bucket (or both) and deletes the local ones older than 14 days. <br/>
This has been tested against single instance databases, primary/secondary/hot standby clusters and [Pgpool/Repmgr](https://github.com/bitnami/bitnami-docker-postgresql-repmgr) clusters.

# Get started
To get started, I've included a [sample cronjob](https://github.com/nataz77/pgbackupd/blob/v1.0/k8s-cron.yaml) in this repo. 
All you need to do is replace: 
* the image (you could use the one built from this repository via [Github Actions](https://github.com/nataz77/pgbackupd/packages/549026)
* the name and the namespace
* the schedule
with your preference and you're good to go in your K8S cluster.

## Environment Variables
* HOST : PostgreSQL host
* USER : PostgreSQL user
* DATABASE: Target database name (use * if you don't have a specific one and want to backup all the databases in the instance/cluster)
* PASSWORD: PostgreSQL user password
* PORT: The PostgreSQL instance port
* OUTPUTDIR: The output directory where the script will place the backup file. (Eg: /data/postgres with no trailing slashes)
* FULLDUMP: Specifies whether to execute pg_dump or pg_dumpall (set to True if you want the full dump, otherwise leave the var unset)
* DEBUG: Set this var to true if you want to enable verbose output from pg_dump/pg_dumpall, otherwise leave this var unset

## Environment variables to enable the upload to a Azure Storage Account
* AZCOPY: Enables the upload (eg: true)
* AZURE_STORAGE_CONNECTION_STRING: The storage account connection string
* AZ_CONTAINER_NAME: The storage account container name
* AZ_ACCOUNT_NAME: The storage account's name associated with the connection string.

## Environment variables to enable S3 copy 
* S3COPY: Enables the upload (eg: true)
* AWS_ACCESS_KEY_ID: The AWS access key 
* AWS_SECRET_ACCESS_KEY: The AWS secret key
* AWS_BUCKET_NAME: The S3 bucket name
