FROM debian:jessie
MAINTAINER Marcello_deSales@intuit.com

RUN apt-get update && \
    apt-get install -y --fix-missing python python-pip cron git python-dev inotify-tools && \
    rm -rf /var/lib/apt/lists/*

RUN pip install s3cmd klein 

ADD s3cfg /root/.s3cfg

ADD server.py /server.py
RUN chmod +x /server.py

ADD start.sh /start.sh
RUN chmod +x /start.sh

ADD sync.sh /sync.sh
RUN chmod +x /sync.sh

CMD [/start.sh]
