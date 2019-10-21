FROM alpine:latest

LABEL maintainer="vdrouard.pro@gmail.com"

# Installation utilitaire(s)
RUN apk update && apk add logrotate which

# Add cron for logrotate
RUN echo "*/15    *       *       *       *       logrotate -vf /etc/logrotate.conf 1>>/cron/logs/logrotate.log 2>&1" >> /etc/crontabs/root

# Configuration logrotate
COPY logrotate_default /etc/logrotate.d/default

# Volumes outils
VOLUME ["/cron/logs","/cron/scripts"]

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Workdir
WORKDIR /cron

ENTRYPOINT ["/entrypoint.sh"]