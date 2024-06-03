#!/bin/bash

source ~/.bash_profile

version=$(echo {$(sudo journalctl -u carv-verifier.service | grep version | tail -1 | cut -d '{' -f 2-) | jq -r '."service.version"')
service=$(sudo systemctl status carv-verifier --no-pager | grep "active (running)" | wc -l)
pid=$(pidof verifier)
network=testnet
chain=testnet
id=carv-$CARV_ID
bucket=node

if [ $service -ne 1 ]
then 
  status="error";
  message="service not running"
else 
  status="ok";
fi

cat << EOF
{
  "id":"$id",
  "machine":"$MACHINE",
  "network":"$network",
  "chain":"$chain",
  "type":"node",
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
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$bucket&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    status,node=$id,machine=$MACHINE status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",network=\"$network\",chain=\"$chain\" $(date +%s%N) 
    "
fi
