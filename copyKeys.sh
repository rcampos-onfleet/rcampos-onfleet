#!/bin/bash

# Copy keys between Redis databases.
# Usage: ./copyKeys.sh localhost 6380 0 localhost 6380 1
# Ref: https://stackoverflow.com/questions/23222616/copy-all-keys-from-one-db-to-another-in-redis

redis_cli=/usr/bin/redis6-cli
redis_password=$(aws secretsmanager get-secret-value --secret-id staging/redis |grep password |cut -d'"' -f7|tr -d '\\')
shost=$1
sport=$2
sdb=$3
thost=$4
tport=$5
tdb=$6

$redis_cli -h "$shost" -p "$sport" -a "$redis_password" -n "$sdb" keys \* | while read -r key; do
    echo "Copying $key"
    $redis_cli  --raw -h "$shost" -p "$sport" -a "$redis_password" -n "$sdb" DUMP "$key" \
        | head -c -1 \
        | $redis_cli  -x -h "$thost" -p "$tport" -a "$redis_password" -n "$tdb" RESTORE "$key" 0
done