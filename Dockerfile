FROM debian:jessie
MAINTAINER Ilya Stepanov <dev@ilyastepanov.com>

RUN apt-get update && \
    apt-get install -y python python-pip cron && \
    rm -rf /var/lib/apt/lists/* && \
    pip install s3cmd

ADD s3cfg /root/.s3cfg
ADD start.sh /start.sh
ADD sync.sh /sync.sh
ADD get.sh /get.sh

RUN chmod +x /start.sh && \
    chmod +x /sync.sh && \
    chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]
