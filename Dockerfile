FROM debian:wheezy
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Install SSH
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*

# sshd needs this directory to run
RUN mkdir -p /var/run/sshd

# Add configuration and script
ADD . /root
WORKDIR /root
RUN mv sshd_config /etc/ssh/sshd_config && \
    chmod +x run

EXPOSE 22

CMD ["./run"]
