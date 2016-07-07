#!/bin/sh
rm info.0.json data.txt
wget -q http://xkcd.com/info.0.json && python -m json.tool info.0.json > data.txt
access_token=DUHIWONTBEGIVINGYOUTHIS
title=`grep -o -P '(?<=safe_title": ").*(?=",)' data.txt`
image_url=`grep -o -P '(?<=img": ").*(?=",)' data.txt`
num=`grep -o -P '(?<=num": ).*(?=,)' data.txt`
curl --silent -k --data "board=354658608094837687&note=$num - $title&image_url=$image_url&link=http://xkcd.com/$num/" https://api.pinterest.com/v1/pins/?access_token=$access_token > /dev/null
