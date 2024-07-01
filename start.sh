#!/bin/bash

source ~/.bash_profile

sudo systemctl restart carv-verifier
sudo journalctl -u carv-verifier.service -f --no-hostname -o cat
