#!/bin/bash

cd ~
git clone https://github.com/carv-protocol/verifier
cd verifier
make build
make init
# make all

printf "[Unit]
Description=Carv Verifier
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/verifier
ExecStart=/root/verifier/bin/verifier -conf /root/verifier/configs/config.yaml
Restart=on-failure
RestartSec=60
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/carv-verifier.service

sudo systemctl daemon-reload
sudo systemctl enable carv-verifier

