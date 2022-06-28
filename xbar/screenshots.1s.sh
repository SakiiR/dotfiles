#!/bin/bash



TRANSFER_URL="https://transfer.sakiir.ovh"
SCREENSHOT_DIRECTORY="$HOME/workspace/Screenshots"
_me="$0"
_ls="/bin/ls"
_find="/usr/bin/find"
_basename="/usr/bin/basename"
_cp="/bin/cp"
_convert="/usr/local/bin/convert"
_open="/usr/bin/open"
_rm="/bin/rm"
_http="/usr/local/bin/http"
_jq="/usr/local/bin/jq"

echo "Clip :computer:"
echo "---"
echo "Clear Screenshot | bash='$0' color=red terminal=false param1=clear refresh=true"
echo "---"
for screenshot in $($_ls -1 $SCREENSHOT_DIRECTORY|tr ' ' '_') ; do
    FILE=$(echo $SCREENSHOT_DIRECTORY/$screenshot | tr '_' ' ')
    echo "$screenshot | bash='$0' terminal=false param1=upload param2='$FILE' refresh=true"
done


if [[ "$1" = "upload" ]] ; then
  new_file="/tmp/$(uuidgen).png"
  bname=`basename ${new_file}`
  cp "${2}" "${new_file}"
  transfer "${new_file}"
  url=`curl --upload-file "${2}" "${TRANSFER_URL}/${bname}"`
  open "${url}"
fi

if [[ "$1" = "clear" ]] ; then
    $_rm -f "$SCREENSHOT_DIRECTORY"/*
fi
