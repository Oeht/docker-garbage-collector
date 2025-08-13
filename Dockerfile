FROM alpine:3.20
RUN apk add --no-cache docker-cli tzdata coreutils
ENV TZ=Europe/Berlin
COPY cleanup.sh /usr/local/bin/cleanup.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /usr/local/bin/cleanup.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
