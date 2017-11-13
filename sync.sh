#!/bin/bash

set -e

echo "Job started: $(date)"

cd /
rm -f backup.tar.gz 
tar --exclude='*.git*' --exclude='*.tar.gz' -czf ../backup.tar.gz ${DATA_PATH}* ${DATA_PATH}.??*

/usr/local/bin/s3cmd sync $PARAMS "/backup.tar.gz" "$S3_PATH"

echo "Job finished: $(date)"
