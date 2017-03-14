marcellodesales/sync-to-s3
======================

Docker container that can backup files, volumes, git repos directly to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync). It can also use a cron job to periodically upload those.

### Usage

    docker run -d [OPTIONS] marcellodesales/sync-to-s3 start.sh 

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

## Docker Compose Example

Run the clone for a Docker Volume using Docker-compose.

```yml
version: "2"

volumes:
  apks: {}

services:
  sync:
    build:
      context: .
    volumes:
      - apks:/apks
      - ./builds:/apks
    environment:
      DATA_PATH: /apks
      ACCESS_KEY: AK**************HQ
      SECRET_KEY: 4hC***************6WpYV
      S3_PATH: s3://my-s3-bucket/test/
    command: /start.sh wait-sync
```

Note that the local directory `builds` is mapped to the directory `/apks` from the volume `apks`.

```
$ docker-compose up                                          
Recreating dockergitbackuptos3_sync_1
Attaching to dockergitbackuptos3_sync_1
sync_1  | Parameter is wait-sync
sync_1  | Will wait until files are at /apks...
sync_1  | Setting up watches.
sync_1  | Watches established.
```

At this point, you can open a new terminal and create file in the directory...

```
$ sudo touch builds/newfile5
```

Since the local dir `builds/` is mapped to a docker volume, the file is then seen
and all the files in the current directory is sync'ed with S3.

```
sync_1  | The file 'newfile5' appeared in directory '/apks/' via 'CREATE'
sync_1  | S3 Bucket Sync: Running the following...
sync_1  | /usr/local/bin/s3cmd sync  "/apks" "s3://my-s3-bucket/test/"
sync_1  | Files...
sync_1  | total 8
sync_1  | drwxr-xr-x  2 root root 4096 Mar 14 08:41 .
sync_1  | drwxr-xr-x 40 root root 4096 Mar 14 08:40 ..
sync_1  | -rw-r--r--  1 root root    0 Mar 14 08:26 newfile
sync_1  | -rw-r--r--  1 root root    0 Mar 14 08:26 newfile2
sync_1  | -rw-r--r--  1 root root    0 Mar 14 08:37 newfile3
sync_1  | -rw-r--r--  1 root root    0 Mar 14 08:40 newfile4
sync_1  | -rw-r--r--  1 root root    0 Mar 14 08:41 newfile5
sync_1  | 
sync_1  | Job started: Tue Mar 14 08:41:03 UTC 2017
sync_1  | upload: '/apks/newfile' -> 's3://my-s3-bucket/test/apks/newfile'  [1 of 5]
 0 of 0     0% in    0s     0.00 B/s  done
sync_1  | upload: '/apks/newfile2' -> 's3://my-s3-bucket/test/apks/newfile2'  [2 of 5]
 0 of 0     0% in    0s     0.00 B/s  done
sync_1  | upload: '/apks/newfile3' -> 's3://my-s3-bucket/test/apks/newfile3'  [3 of 5]
 0 of 0     0% in    0s     0.00 B/s  done
sync_1  | upload: '/apks/newfile4' -> 's3://my-s3-bucket/test/apks/newfile4'  [4 of 5]
 0 of 0     0% in    0s     0.00 B/s  done
sync_1  | upload: '/apks/newfile5' -> 's3://my-s3-bucket/test/apks/newfile5'  [5 of 5]
 0 of 0     0% in    0s     0.00 B/s  done
sync_1  | Job finished: Tue Mar 14 08:41:07 UTC 2017
dockergitbackuptos3_sync_1 exited with code 0
```
