#!/bin/sh
COUNTER=0
while [ $COUNTER -lt 1687 ]
do
  COUNTER=$((COUNTER+1))
  rm info.0.json data.txt
  access_token=DUHIWONTBEGIVINGYOUTHIS
  wget -q http://xkcd.com/$COUNTER/info.0.json && python -m -json.tool info.0.json > data.txt
  title=`grep -o -P '(?<=safe_title": ").*(?=",)' data.txt`
  image_url=`grep -o -P '(?<=img": ").*(?=",)' data.txt`
  curl --silent -k --data "board=354658608094837687&note=$COUNTER - $title&image_url=$image_url&link=http://xkcd.com/$COUNTER/" https://api.pinterest.com/v1/pins/?access_token=$access_token > /dev/null
  sleep 4
done
