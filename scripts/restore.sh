#!/bin/bash

i3-msg "workspace 1; append_layout ~/.i3/workspace-1.json"
(termite -e weechat &)
~/.scripts/wait_window.sh 'weechat'

i3-msg "workspace 2; append_layout ~/.i3/workspace-2.json"
(/usr/bin/discord &)
~/.scripts/wait_window.sh 'discord'
sleep 2
(/usr/bin/whatsapp-web-desktop &)
~/.scripts/wait_window.sh 'whats-app'

i3-msg "workspace 3; append_layout ~/.i3/workspace-3.json"
(/usr/bin/google-chrome-stable &)
~/.scripts/wait_window.sh 'google'

i3-msg "workspace 4; append_layout ~/.i3/workspace-4.json"
(keepassxc &)
~/.scripts/wait_window.sh 'keepassxc'

i3-msg "workspace 5; append_layout ~/.i3/workspace-5.json"
(termite &)
~/.scripts/wait_window.sh 'termite'
