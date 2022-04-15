FROM debian:buster-slim

RUN apt-get update
RUN apt-get install -y net-tools curl procps cron dumb-init vim net-tools openssh-server

# RUN groupadd --gid 10001 sftp
# RUN useradd -m --uid 10001 --gid 10001 sftp

RUN groupadd --gid 10002 stealth
RUN useradd -m --uid 10002 --gid 10002 stealth

RUN echo -n 'stealth:cZASxjQsRsyJ9OG93iRt' | chpasswd

# RUN echo "sftp ALL=(root) /usr/local/bin/create-sftp-user, useradd, chown -R stealth.stealth /home/stealth" >> /etc/sudoers

RUN rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/
COPY files/entrypoint /

EXPOSE 22

# RUN mkdir -p /etc/sftp/ /home/sftp /var/run/sftp/ /var/run/sshd \
#     && chown -R sftp.sftp /etc/sftp/ /home/sftp /var/run/sftp/ /etc/ssh/ /var/run/sshd

RUN mkdir -p /home/stealth \
    && chown -R stealth.stealth /home/stealth

# USER sftp

ENTRYPOINT ["/entrypoint"]

CMD [ "sshd" ]