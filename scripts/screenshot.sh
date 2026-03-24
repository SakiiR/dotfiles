#!/bin/bash

. ~/.transfer

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --transfer)
      TRANSFER=YES
      shift # past argument
      ;;
    --clip)
      CLIP=YES
      shift # past argument
      ;;
    --notify)
      NOTIFY=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

output=~/Pictures/Screenshots/capture_$(date +"%Y-%m-%d_%H-%M").png
stdout=`maim -s "$output"`

notify() {
  if [ "${NOTIFY}" = "YES" ]; then
    notify-send "$1"
  fi
}

notify "Screenshot done!"

if [ "${TRANSFER}" = "YES" ]; then
    stdout=`transfer "$output"`
    notify "Uploaded!"
fi

if [ "${CLIP}" = "YES" ]; then
  echo -n "${stdout}"
  echo -n "${stdout}"|xclip -sel clip
  notify "Copied to clipboard!"
fi




