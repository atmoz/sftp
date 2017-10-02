FROM debian:stretch
MAINTAINER Adrian Dvergsdal [atmoz.net]

# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get update && \
    apt-get -y install openssh-server postgresql sshfs && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
COPY README.md /

RUN echo "*/5 * * * * /entrypoint;echo done >> /var/log/ups" >tmpfile \
    && chmod +x /entrypoint

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
