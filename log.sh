#!/bin/bash
sudo journalctl -u carvd.service -f --no-hostname -o cat
