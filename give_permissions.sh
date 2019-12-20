#!/bin/sh

if [ $(id -u) -ne 0 ]; then
  echo 'Must be executed as root.'
  exit 1
fi

BLIGHT_EXE=$(which blight)

if [ "$#" -eq 1 ]; then
  BLIGHT_EXE="$1"
fi

if [ -z "$BLIGHT_EXE" ]; then
  echo 'blight must be in the PATH.'
  echo 'Suggestion: run `stack install` or run this script as `./give_persissions PATH_TO_BLIGHT`.'
  exit 1
fi

setcap cap_dac_override=ep "$BLIGHT_EXE"
