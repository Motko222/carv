#!/bin/bash
#sudo journalctl -u carv-verifier.service -f --no-hostname -o cat

docker logs --tail 100 verifier
