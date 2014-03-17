set -xv

VERSION=0.03
JOB="Backup mysql RDS instance and push to S3"
DATE=`date +%d%m%Y`
DSTDIR=/media/ephemeral0/
DSTFILE=kplus_blended_live.mysql
FILE=$DSTDIR/$DSTFILE.$DATE.bz2
USER=moodleadmin
PASSWD=PASSWORD
RDS=kplus-backup.cc3ocpsgoulu.eu-west-1.rds.amazonaws.com
DB=blended_live
BUCKET=kaplan-db-backups
TO=/kplus/
REGION=eu-west
CREDS=/root/creds
IAM=kplus-rds-backup
KEEP=7
RMDATE=`date --date="$KEEP days ago" +%d%m%Y`


logger "Start mysqldump $FILE"
mysqldump -u "$USER" -p"$PASSWD" -h "$RDS" $DB | bzip2 > $FILE 
if [ $? -gt 0 ]; then 
 	logger "FAILED: MYSQL backup"
	exit 10
else
	logger "SUCCESS: MYSQL backup"
fi

logger "Starting S3 upload of $FILE"
aws s3 cp  $FILE  s3://$BUCKET/$TO --region=eu-west-1
if [ $? -gt 0 ]; then
        logger "FAILED: S3 upload"
	exit 11
else
        logger "SUCCESS: S3 upload"
fi
rm $DSTDIR/$DSTFILE.$RMDATE.bz2


exit 0
	
