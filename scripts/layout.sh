#!/bin/bash

i3-msg 'workspace 1; exec /usr/bin/termite -e "weechat"'
sleep 0.1
i3-msg 'workspace 2; exec /usr/bin/whatsapp-web-desktop'
sleep 1
i3-msg 'workspace 3; exec /usr/bin/google-chrome-stable'
sleep 2
i3-msg 'workspace 4; exec /usr/local/bin/keepassx'
sleep 1
i3-msg 'workspace 5; exec /usr/bin/termite'
