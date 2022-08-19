FROM ubuntu:22.04

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils iputils-ping less curl ca-certificates gnupg
RUN curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main' >/etc/apt/sources.list.d/pgdg.list
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y pgbadger

ENTRYPOINT ["/bin/bash", "-c", "while : ; do sleep 60 ; done" ]

