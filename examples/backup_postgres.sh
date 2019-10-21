#!/bin/sh

# VAR
LOG_FILE=/cron/logs/pgdump.log

# Check if pg_dump is present and install
which pg_dump 1>/dev/null 2>&1 || apk --no-cache add postgresql-client findutils

if [[ -z ${PG_USER} || -z ${PG_PASS} || -z ${PG_DBNAME} || -z ${PG_HOST} ]]
then
  echo 'one or more variables are undefined, list of var : PG_DBNAME / PG_USER / PG_HOST / PG_PASS' >> ${LOG_FILE}
  exit 1
fi

# Dump
echo "$(date +%Y-%m-%d_%H_%M_%S) - Dump database" >> ${LOG_FILE}
export PGPASSWORD="${PG_PASS}"
pg_dump -h "${PG_HOST}" -U "${PG_USER}" -d "${PG_DBNAME}" > /backups/pg/${PG_DBNAME}_$(date +%Y-%m-%d_%H_%M_%S).sql

# Clean files
if [[ -z ${PG_DUMP_MIN_RETENTION} ]]
then
  PG_DUMP_MIN_RETENTION=1440
fi
echo "$(date +%Y-%m-%d_%H_%M_%S) - Delete files greater than ${PG_DUMP_MIN_RETENTION} minutes" >> ${LOG_FILE}
echo "$(date +%Y-%m-%d_%H_%M_%S) - List of files : $(find /backups/pg/ -name "*.sql" -mmin +${PG_DUMP_MIN_RETENTION})" >> ${LOG_FILE}
find /backups/pg/ -name "*.sql" -mmin +${PG_DUMP_MIN_RETENTION} -exec rm {} \; 1>>${LOG_FILE} 2>&1
