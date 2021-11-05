#!/bin/bash
# NOTE : Quote it else use array to avoid problems #
FILES="data/batch_sessions/*"
for f in $FILES
do
  echo "Processing $f file..."
  python $PATH_TO_SESSION_VIEWER --session $f --output-folder data/videos
done