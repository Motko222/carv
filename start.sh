#!/bin/bash

source ~/.bash_profile

sudo systemctl restart carvd
sudo systemctl status carvd
