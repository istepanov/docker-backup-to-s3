#!/bin/bash

instance_id=`curl --max-time 2 http://169.254.169.254/latest/meta-data/instance-id/`
if [ "$instance_id" != "" ]; then
    echo "Running in AWS will use IAM role for S3 credentials if instance has an IAM role"
    instance_profile=`curl --max-time 2 http://169.254.169.254/latest/meta-data/iam/security-credentials/`
    if [[ -z $ACCESS_KEY && "$instance_profile" != "" ]]; then
        aws_access_key_id=`curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g'`
        export ACCESS_KEY=${aws_access_key_id}
    fi

    if [[ -z $SECRET_KEY && "$instance_profile" != "" ]]; then
        aws_secret_access_key=`curl http://169.254.169.254/latest/meta-data/iam/security-credentials/${instance_profile} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g'`
        export SECRET_KEY=${aws_secret_access_key}
    fi
else
    echo "Not running in AWS so ACCESS_KEY and SECRET_KEY must be specified"
fi


set -e

: ${ACCESS_KEY:?"ACCESS_KEY env variable is required"}
: ${SECRET_KEY:?"SECRET_KEY env variable is required"}
: ${S3_PATH:?"S3_PATH env variable is required"}
export DATA_PATH=${DATA_PATH:-/data/}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [[ "$1" == 'no-cron' ]]; then
    exec /sync.sh
elif [[ "$1" == 'delete' ]]; then
    exec /usr/local/bin/s3cmd del -r "$S3_PATH"
else
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PARAMS='$PARAMS'"
    CRON_ENV="$CRON_ENV\nDATA_PATH='$DATA_PATH'"
    CRON_ENV="$CRON_ENV\nS3_PATH='$S3_PATH'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /sync.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    cron
    tail -f "$LOGFIFO"
fi
