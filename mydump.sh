# set -xv
VERSION=0.02
JOB="Backup mysql RDS instance and push to S3"
DATE=`date +%d%m%Y`
FILE=/media/ephemeral0/kplus_blended_live.mysql.$DATE.bz2
USER=moodleadmin
PASSWD=KPlus+KPlus
RDS=kplus-backup.cc3ocpsgoulu.eu-west-1.rds.amazonaws.com
DB=blended_live
BUCKET=kaplan-db-backups
FROM=/media/ephemeral0/
TO=/kplus/
REGION=eu-west
CREDS=/root/creds
IAM=kplus-rds-backup
S3CMD=/usr/bin/s3cmd

# Get our credentials from metadata
# /root/fetchcreds.sh $IAM $CREDS

logger "Start mysqldump $FILE"
mysqldump -u "$USER" -p"$PASSWD" -h "$RDS" $DB | bzip2 > $FILE 
if [ $? -gt 0 ]; then 
 	logger "FAILED: MYSQL backup"
else
	logger "SUCCESS: MYSQL backup"
fi

logger "Starting S3 upload of $FILE"
aws s3 cp  $FILE  s3://$BUCKET/$TO --region=eu-west-1
if [ $? -gt 0 ]; then
        logger "FAILED: S3 upload"
else
        logger "SUCCESS: S3 upload"
fi
	
