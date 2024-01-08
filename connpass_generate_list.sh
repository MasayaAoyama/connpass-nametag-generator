#!/bin/bash

FILENAME=$1
OUTPUT_FILENAME=./output.csv

if [ -z "$FILENAME" ]; then
  echo "please run with event participants list file."
  exit 1
fi

declare -a CONNPASS_IDS

# read files
while IFS= read -r line; do
    CONNPASS_IDS+=("$line")
done <<< "$(cat $FILENAME | cut -d "," -f 2)"

for i in `seq 1 ${#CONNPASS_IDS[@]}`; do
    curl -s https://connpass.com/user/${CONNPASS_IDS[$i]}/ > /tmp/user_request_cache.html

    NAME="$(cat /tmp/user_request_cache.html | grep -A1 '<h2 class="title_2">' | tail -n 1 | sed -r 's/^[[:space:]]*|[[:space:]]*$//g')"
    TWITTER_ID="$(cat /tmp/user_request_cache.html | grep http://twitter.com/ | head -n 1 | grep -v connpass_jp | cut -d '"' -f 2 | cut -d "/" -f 4)"
    IMG_URL="$(cat /tmp/user_request_cache.html | grep '<img src="https://media.connpass.com/thumbs/' | head -n 1  | cut -d '"' -f 2)"

    echo "$NAME,$TWITTER_ID,$IMG_URL"
done > $OUTPUT_FILENAME
