FROM debian:buster-slim

RUN addgroup -S 10001 \
    && adduser -S 10001 -G 10001

USER 1001

RUN apt-get update
RUN apt-get install -y net-tools curl procps cron dumb-init vim net-tools

RUN apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]

CMD ["sshd"]
