#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

docker_status=$(docker inspect verifier | jq -r .[].State.Status)
errors=$(docker logs verifier 2>&1 | grep $(date --utc +%F) | grep -c ERROR)

case $docker_status in
  running) status=ok; message="errors $errors" ;;
  restarting) status=warning; message="docker is restarting" ;;
  *) status=error; message="docker not running" ;;
esac

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
     "id":"$folder",
     "machine":"$MACHINE",
     "grp":"node",
     "owner":"$OWNER"
  },
  "fields": {
      "network":"mainnet",
      "chain":"mainnet",
      "version":"$version",
      "status":"$status",
      "message":"$message",
      "errors":$errors
  }
}
EOF

cat $json | jq
