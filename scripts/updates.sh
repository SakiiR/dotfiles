#!/bin/bash

sudo apt -y update 
sudo apt -y upgrade 
sudo snap refresh 
sudo fwupdmgr update

DEB_FILE="/tmp/discord-update.deb"
UPDATE_URL="https://discord.com/api/download/stable?platform=linux&format=deb"

echo "Downloading DEB file"                             && \
curl --progress-bar -L "${UPDATE_URL}" -o "${DEB_FILE}" && \
echo "Downloaded DEB file"                              && \
sudo apt install -y "${DEB_FILE}" > /dev/null           && \
echo "Installed DEB file"                               && \
rm -f "${DEB_FILE}"                                     && \
echo "Removed DEB file"                                 

