FROM debian:jessie
MAINTAINER Adrian Dvergsdal [atmoz.net]

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Step 1: sshd needs /var/run/sshd/ to run
# Step 2: Remove keys, they will be generated later by entrypoint
#         (unique keys for each container)
RUN mkdir -p /var/run/sshd && \
    rm /etc/ssh/ssh_host_*key*

COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
COPY README.md /

VOLUME /etc/ssh

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
