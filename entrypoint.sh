#!/bin/sh

# Read env var begin by "CRON_" and add on crontab
for cronkey in $(env | grep "^CRON_.*_SCRIPT=.*" | cut -d'=' -f1 | cut -d'_' -f2)
do
    echo "Traitement du cron id : ${cronkey}"
    CRON_TRIG=$(env | grep "^CRON_${cronkey}_TRIGGER=.*" | cut -d'=' -f2-)
    CRON_SCRIPT=$(env | grep "^CRON_${cronkey}_SCRIPT=.*" | cut -d'=' -f2-)
    echo "--> Trigger ${CRON_TRIG}"
    echo "--> Script ${CRON_SCRIPT}"
    chmod +x /cron/scripts/${CRON_SCRIPT}
    echo "----> Ajout dans le cron : ${CRON_TRIG} /cron/scripts/${CRON_SCRIPT} >> /cron/logs/${cronkey}.log"
    echo "${CRON_TRIG} /cron/scripts/${CRON_SCRIPT} >> /cron/logs/${cronkey}.log" >> /etc/crontabs/root
done

# Run cron
crond -f