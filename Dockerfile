FROM debian:buster
MAINTAINER Adrian Dvergsdal [atmoz.net]

COPY files/ldap.debconf /ldap.debconf
RUN debconf-set-selections < /ldap.debconf

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server libpam-ldapd libnss-ldapd libpam-script && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/enable_ldap /usr/local/bin
COPY files/ldap-pam-script.sh /usr/share/libpam-script/
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
