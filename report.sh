#!/bin/bash

hdate () {
  awk -v date="$(date +%s -d "$1")" -v now="$(date +%s)" '
    BEGIN {  diff = now - date;
       if (diff > (24*60*60)) printf "%.0f days ago", diff/(24*60*60);
       else if (diff > (60*60)) printf "%.0f hours ago", diff/(60*60);
       else if (diff > 60) printf "%.0f minutes ago", diff/60;
       else printf "%s seconds ago", diff;
    }'
}

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile

version=$(echo {$(sudo journalctl -u carv-verifier.service | grep version | tail -1 | cut -d '{' -f 2-) | jq -r '."service.version"')
service=$(sudo systemctl status carv-verifier --no-pager | grep "active (running)" | wc -l)
pid=$(pidof verifier)
last=$(sudo journalctl -u carv-verifier.service --no-hostname -o cat | grep "tx hash" | tail -1 | jq -r .ts)

if [ $service -ne 1 ]
then
  status="error";
  message="service not running"
else
  status="ok";
  message="last tx: "$(hdate $last)
fi

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
      "chain":"alphanet",
      "version":"$version",
      "status":"$status",
      "message":"$message",
      "service":$service,
      "pid":$pid
  }
}
EOF

cat $json
