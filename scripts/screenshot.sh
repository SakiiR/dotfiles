#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --clip)
      CLIP=YES
      shift # past argument
      ;;
    --clip-image)
      CLIP_IMAGE=YES
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

# Use grim + slurp for Wayland region selection
region=$(slurp)
if [ -z "$region" ]; then
  exit 1
fi

output=~/Pictures/Screenshots/capture_$(date +"%Y-%m-%d_%H-%M-%S-%3N").png
grim -g "$region" "$output"

notify() {
  if [ "${NOTIFY}" = "YES" ]; then
    dunstify "$1"
  fi
}

notify "Screenshot done!"

if [ "${CLIP_IMAGE}" = "YES" ]; then
  wl-copy --type image/png < "$output"
  notify "Image copied to clipboard!"
elif [ "${CLIP}" = "YES" ]; then
  echo -n "$output" | wl-copy
  notify "Copied to clipboard!"
fi
