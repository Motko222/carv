#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

#version=$(echo {$(sudo journalctl -u carv-verifier.service | grep version | tail -1 | cut -d '{' -f 2-) | jq -r '."service.version"')
#service=$(sudo systemctl status carv-verifier --no-pager | grep "active (running)" | wc -l)
#last=$(sudo journalctl -u carv-verifier.service --no-hostname -o cat | grep "tx hash" | tail -1 | jq -r .ts)

#if [ $service -ne 1 ]
#then
#  status="error";
#  message="service not running"
#else
#  status="ok";
#  message="last tx: "$(hdate $last)
#fi

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

cat $json
