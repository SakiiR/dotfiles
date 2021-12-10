#!/bin/bash

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
    slug=$($_http --ignore-stdin    \
      --default-scheme=https        \
      --verify=no                   \
      --form                        \
      POST                          \
      'https://framapic.org/'       \
      'format=json'                 \
      'first-view=0'                \
      'delete-day=1'                \
      'crypt=0'                     \
      'keep-exif=0'                 \
      "file@${2}" | $_jq -r '.msg.short')
    data="https://framapic.org/${slug}"
    open $data
fi

if [[ "$1" = "clear" ]] ; then
    $_rm -f "$SCREENSHOT_DIRECTORY"/* > /tmp/output.txt
fi
