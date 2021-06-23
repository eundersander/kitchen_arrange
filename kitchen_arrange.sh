#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo "Usage: specify a scene_instance.json filepath to load."
  exit 1
fi

case "$1" in
    *.scene_instance.json ) ;;
    * ) 
      echo "Unexpected argument $1. Specify a scene_instance.json filepath to load."
      exit 1
      ;;
esac

if ! test -f "$1"; then
  echo "Error: Scene filepath $1 not found."
  exit 1
fi

if [[ -z "$PATH_TO_ARRANGE_RECORDER" ]]; then
  echo "PATH_TO_ARRANGE_RECORDER is undefined"
  exit 1
fi

if ! test -f "$PATH_TO_ARRANGE_RECORDER"; then
    echo "Error: Executable filepath $PATH_TO_ARRANGE_RECORDER not found."
fi

$PATH_TO_ARRANGE_RECORDER --scene $1 --dataset data/lighthouse_kitchen_dataset/lighthouse_kitchen.scene_dataset_config.json --arrange-config data/default.arrange_config.json "${@:2}"