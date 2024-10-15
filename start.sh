#!/bin/bash

source ~/.bash_profile

#sudo systemctl restart carv-verifier
#sudo journalctl -u carv-verifier.service -f --no-hostname -o cat

docker stop verifier
docker rm verifier
docker run -d --name verifier --restart always -v /root/verifier/configs:/data/conf  carvprotocol/verifier:mainnet-amd64
