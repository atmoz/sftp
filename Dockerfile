FROM debian:stretch

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN  apt-get update \
  && apt-get upgrade -y \
  && apt-get dist-upgrade -y \
  && apt-get install -y \
    fail2ban \
    openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /var/run/sshd \
  && rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/jail.local /etc/fail2ban/
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]