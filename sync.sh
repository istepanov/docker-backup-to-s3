#!/bin/bash

set -e

echo "S3 Bucket Sync: Running the following..."
echo "/usr/local/bin/s3cmd sync $PARAMS \"$DATA_PATH\" \"$S3_PATH\""
echo "Files..."
ls -la $DATA_PATH
echo ""
echo "Job started: $(date)"

/usr/local/bin/s3cmd sync $PARAMS "$DATA_PATH" "$S3_PATH"

echo "Job finished: $(date)"
