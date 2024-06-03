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
WorkingDirectory=/root/carv
ExecStart=/root/carv/bin/verifier -conf /root/carv/configs/config.yaml
Restart=on-failure
RestartSec=60
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/carvd.service

sudo systemctl daemon-reload
sudo systemctl enable carvd

