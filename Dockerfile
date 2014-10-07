FROM debian:wheezy
MAINTAINER Adrian Dvergsdal

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server

RUN mkdir -p /var/run/sshd
RUN addgroup --system sftp

ADD . /root
WORKDIR /root
RUN mv sshd_config /etc/ssh/sshd_config

EXPOSE 22

CMD ["/bin/bash", "run"]
