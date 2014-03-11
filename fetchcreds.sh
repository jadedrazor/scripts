#set -xv
IAM=$1
CREDS=$2
TMPCREDS=$2.tmp

wget -q -O $TMPCREDS http://169.254.169.254/latest/meta-data/iam/security-credentials/$IAM
SECRET_KEY=`grep SecretAccessKey $TMPCREDS | awk -F\" '{ print $4 }'`
ACCESS_KEY=`grep AccessKeyId  $TMPCREDS | awk -F\" '{ print $4 }'`
TOKEN=`grep Token  $TMPCREDS | awk -F\" '{ print $4 }'`
echo '[default]' > $CREDS 
echo access_key = $ACCESS_KEY  >> $CREDS
echo secret_key = $SECRET_KEY >> $CREDS
echo security_token = $TOKEN >> $CREDS
rm $TMPCREDS
