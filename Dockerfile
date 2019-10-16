FROM debian:buster-slim
MAINTAINER Joshua Burnett [yakworks.org]

ARG VCS_REF
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/yakworks/docker-sftp"

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN  apt-get update \
  && apt-get upgrade -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    rsyslog \
    supervisor \
    openssh-server \
    fail2ban \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/log/*.log \
  && mkdir -p /var/run/sshd \
  && rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/jail.local /etc/fail2ban/
COPY files/entrypoint /
COPY files/sshd.conf /etc/rsyslog.d/sshd.conf
COPY files/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22

ENTRYPOINT ["/entrypoint"]