istepanov/backup-to-s3
======================

Docker container that periodically backups files to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync) and cron.

### Usage

    docker run -d [OPTIONS] istepanov/backup-to-s3

### Parameters:

* `-e ACCESS_KEY=<AWS_KEY>`: Your AWS key.
* `-e SECRET_KEY=<AWS_SECRET>`: Your AWS secret.
* `-e S3_PATH=s3://<BUCKET_NAME>/<PATH>/`: S3 Bucket name and path. Should end with trailing slash.
* `-e GIT_REPO=git@github.company.com:org/repo-config-reference-service-config.git`: GitHub repo to clone the master.
* `-v $HOME/.ssh:/root/.ssh`: In case you use a git URL and require to use ssh keys.
* `-v /path/to/backup:/data:ro`: mount target local folder to container's data folder. Content of this folder will be synced with S3 bucket.

### Optional parameters:

* `-e PARAMS="--dry-run"`: parameters to pass to the sync command ([full list here](http://s3tools.org/usage)).
* `-e DATA_PATH=/data/`: container's data folder. Default is `/data/`. Should end with trailing slash.
* `-e 'CRON_SCHEDULE=0 1 * * *'`: specifies when cron job starts ([details](http://en.wikipedia.org/wiki/Cron)). Default is `0 1 * * *` (runs every day at 1:00 am).
* `no-cron`: run container once and exit (no cron scheduling).

### Examples:

Run upload to S3 everyday at 12:00pm:

```
    docker run -d \
        -e ACCESS_KEY=myawskey \
        -e SECRET_KEY=myawssecret \
        -e S3_PATH=s3://my-bucket/backup/ \
        -e 'CRON_SCHEDULE=0 12 * * *' \
        -v /home/user/data:/data:ro \
        istepanov/backup-to-s3
```

Run once then delete the container:

```
    docker run --rm \
        -e ACCESS_KEY=myawskey \
        -e SECRET_KEY=myawssecret \
        -e S3_PATH=s3://my-bucket/backup/ \
        -v /home/user/data:/data:ro \
        istepanov/backup-to-s3 no-cron
```

Run once to delete from s3 then delete the container:

```
    docker run --rm \
        -e ACCESS_KEY=myawskey \
        -e SECRET_KEY=myawssecret \
        -e S3_PATH=s3://my-bucket/backup/ \
        istepanov/backup-to-s3 delete
```

Run the clone for a Git Repo

```
docker run -ti -e ACCESS_KEY=************
               -e SECRET_KEY=***********
               -e S3_PATH=s3://springapp-config
               -e GIT_REPO=git@github.company.com:org/repo-config-reference-service-config.git
               -v $HOME/.ssh:/root/.ssh backup-s3 no-cron
```
