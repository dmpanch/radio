#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process and put it in the background
sudo -u icecast2 icecast -c /usr/share/icecast/icecast.xml &

sleep 5

sudo -u mpd mpd --stdout  --no-daemon &

sleep 5

# Start the helper process
sudo -u root python3 /mpddj/main.py
