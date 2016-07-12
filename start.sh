#!/bin/bash

set -e

if [[ -n "$ACCESS_KEY"  &&  -n "$SECRET_KEY" ]]; then
    echo "
[default]
bucket_location = US
cloudfront_host = cloudfront.amazonaws.com
default_mime_type = binary/octet-stream
delete_removed = False
dry_run = False
enable_multipart = True
encoding = ANSI_X3.4-1968
encrypt = False
follow_symlinks = False
force = False
get_continue = False
gpg_command = /usr/bin/gpg
gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s
gpg_passphrase =
guess_mime_type = True
host_base = s3.amazonaws.com
host_bucket = %(bucket)s.s3.amazonaws.com
human_readable_sizes = False
invalidate_on_cf = False
list_md5 = False
log_target_prefix =
mime_type =
multipart_chunk_size_mb = 15
preserve_attrs = True
progress_meter = True
proxy_host =
proxy_port = 0
recursive = False
recv_chunk = 4096
reduced_redundancy = False
send_chunk = 4096
simpledb_host = sdb.amazonaws.com
skip_existing = False
socket_timeout = 300
urlencoding_mode = normal
use_https = True
verbosity = WARNING
website_endpoint = http://%(bucket)s.s3-website-%(location)s.amazonaws.com/
website_error =
website_index = index.html
access_key=$ACCESS_KEY
secret_key=$SECRET_KEY
" > /root/.s3cmd
else
    echo "No ACCESS_KEY and SECRET_KEY env variable found, assume use of IAM"
fi

: ${S3_PATH:?"S3_PATH env variable is required"}

export DATA_PATH=${DATA_PATH:-/data/}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}

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
