Docker Backup to Amazon S3
===================

Docker container that periodically backups files to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync) and cron.

### Usage

	docker run -d [OPTIONS] istepanov/backup-to-s3

### Parameters:

* `-e ACCESS_KEY=<AWS_KEY>`: Your AWS key.
* `-e SECRET_KEY=<AWS_SECRET>`: Your AWS secret.
* `-e S3_PATH=s3://<BUCKET_NAME>/<PATH>/`: S3 Bucket name and path. Should end with trailing slash. 
* `-v /path/to/backup:/data:ro`: mount target local folder to container's data folder.

### Optional parameters:

* `-e DATA_PATH=/data/`: container's data folder. Default is `/data/`. Should end with trailing slash.
* `-e 'CRON_SCHEDULE=0 1 * * *'`: specifies when cron job starts ([details](http://en.wikipedia.org/wiki/Cron)). Default is `0 1 * * *` (runs every day at 1:00 am). 

### Example:

    docker run -d \
    	-e ACCESS_KEY=fakeawskey \
		-e SECRET_KEY=fakeawssecret \
		-e S3_PATH=s3://my-bucket/backup/ \
		-v /home/user/data:/data:ro	 \	
		istepanov/backup-to-s3
