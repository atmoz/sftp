FROM debian:buster-slim

RUN apt update && \
    apt install -y git gnupg && \
    rm -rf /var/lib/apt/lists/*

#RUN apk add --no-cache git gnupg

COPY ./public-keys/atmoz.asc /tmp/atmoz.asc
RUN gpg --import /tmp/atmoz.asc

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
