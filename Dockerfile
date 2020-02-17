FROM debian:stretch
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server cron && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/refresh-users-cron /etc/cron.d/
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/add-new-users /usr/local/bin/
COPY files/entrypoint /

RUN chmod 0644 /etc/cron.d/refresh-users-cron
RUN crontab /etc/cron.d/refresh-users-cron

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
