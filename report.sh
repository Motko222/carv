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

source ~/.bash_profile

version=$(echo {$(sudo journalctl -u carv-verifier.service | grep version | tail -1 | cut -d '{' -f 2-) | jq -r '."service.version"')
service=$(sudo systemctl status carv-verifier --no-pager | grep "active (running)" | wc -l)
pid=$(pidof verifier)
last=$(sudo journalctl -u carv-verifier.service --no-hostname -o cat | grep "tx hash" | tail -1 | jq -r .ts)

chain=$CARV_CHAIN
network=$CARV_NETWORK
type=$CARV_TYPE
owner=$OWNER
id=$CARV_ID
chain=$CARV_CHAIN
group=$CARV_GROUP

if [ $service -ne 1 ]
then
  status="error";
  message="service not running"
else
  status="ok";
  message="last tx: "$(hdate $last)
fi

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "network":"$network",
  "chain":"$chain",
  "version":"$version",
  "status":"$status",
  "message":"$message",
  "service":$service,
  "pid":$pid,
  "updated":"$(date --utc +%FT%TZ)"
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,owner=$owner,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",network=\"$network\",type=\"$type\" $(date +%s%N)
    "
fi
