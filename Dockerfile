FROM debian:buster-slim

ARG STEALTH_USER_PASSWORD=stealth_password

RUN apt-get update
RUN apt-get install -y net-tools curl procps cron dumb-init vim net-tools openssh-server

RUN groupadd --gid 10001 stealth
RUN useradd -m --uid 10001 --gid 10001 stealth

RUN echo -n "stealth:${STEALTH_USER_PASSWORD}" | chpasswd

RUN rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/
COPY files/entrypoint /

EXPOSE 22

RUN mkdir -p /var/run/sshd \
    && chown -R stealth.stealth /etc/ssh/ /var/run/sshd

RUN mkdir -p /home/stealth \
    && chown -R stealth.users /home/stealth

RUN chmod 644 /etc/shadow

USER stealth

ENTRYPOINT ["/entrypoint"]

CMD [ "sshd" ]