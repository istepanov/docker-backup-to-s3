FROM debian:stable

RUN apt update && \
    apt install -y python3-pip cron && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages s3cmd

ADD s3cfg /root/.s3cfg

ADD start.sh /start.sh
RUN chmod +x /start.sh

ADD sync.sh /sync.sh
RUN chmod +x /sync.sh

ADD get.sh /get.sh
RUN chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]
