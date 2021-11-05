#!/bin/bash
# NOTE : Quote it else use array to avoid problems #
FILES="data/batch_sessions/*"
for f in $FILES
do
  echo "Processing $f file..."
  python ../habitat-sim3/tools/arrange_session_viewer.py --session $f --output-folder data/videos
done