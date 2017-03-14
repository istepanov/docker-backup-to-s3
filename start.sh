#!/bin/bash

set -e

: ${ACCESS_KEY:?"ACCESS_KEY env variable is required"}
: ${SECRET_KEY:?"SECRET_KEY env variable is required"}
: ${S3_PATH:?"S3_PATH env variable is required"}

export DATA_PATH=${DATA_PATH:-/data/}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

echo "Parameter is $1"

if [[ "$1" == 'git' ]]; then
    echo "Backing up git repos..."
    : ${GIT_REPO:?"GIT_REPO env variable is required"}
    rm -rf $DATA_PATH
    git clone $GIT_REPO $DATA_PATH
    rm -rf $DATA_PATH/.git
    exec /sync.sh

elif [[ "$1" == 'wait-sync' ]]; then
    # http://unix.stackexchange.com/questions/24952/script-to-monitor-folder-for-new-files/24955#24955
    # http://stackoverflow.com/questions/30109469/how-to-get-inotifywait-to-stop-after-a-memory-dump-is-complete/30110041#30110041
    echo "Will wait until files are at $DATA_PATH..."
    inotifywait $DATA_PATH -e create -e moved_to |
      while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'"
        # do something with the file
      done
    exec /sync.sh

elif [[ "$1" == 'no-cron' ]]; then
    echo "Sync the directory $DATA_DIR..."
    exec /sync.sh

elif [[ "$1" == 'delete' ]]; then
    echo "Delete files from $S3_PATH"
    exec /usr/local/bin/s3cmd del -r "$S3_PATH"

else
    echo "Executing Cron..."
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
