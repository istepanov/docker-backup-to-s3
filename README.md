Docker Backup to Amazon S3
===================

Docker container that backups files to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync). It doesn't upload files that has already been uploaded to S3. Upload happens once per day at noon.

### Usage

	docker run -d [OPTIONS] istepanov/backup-to-s3

### Options:

* `-e ACCESS_KEY=<AWS_KEY>`: Your AWS key. Required.
* `-e SECRET_KEY=<AWS_SECRET>`: Your AWS secret. Required.
* `-e S3_PATH=s3://<BUCKET_NAME>/<PATH>/`: S3 Bucket name and path. Should end with trailing slash. Required.
* `-e DATA_PATH=/data/`: container's data folder. Default is `/data/`. Should end with trailing slash. Optional.  
*  `-v /path/to/backup:/data:ro`: mount target local folder to container's data folder. Required.

### Example:

    docker run -d && \
    	-e ACCESS_KEY=fakeawskey
		-e SECRET_KEY=fakeawssecret
		-e S3_PATH=s3://my-bucket/backup/
		-v /home/user/data:/data:ro
		istepanov/backup-to-s3
