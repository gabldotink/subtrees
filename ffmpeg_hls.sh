#!/bin/bash
ffmpeg -y \
    -i '【Battle of Hunters】きりたんが95円のバトロワゲーを遊ぶお話 #1【VOICEROID実況】-sm39132582.mp4' \
    -i '【Battle of Hunters】きりたんが95円のバトロワゲーを遊ぶお話 #1【VOICEROID実況】-sm39132582.jpn.ass' \
    -c:v libx264 -c:a aac -b:a 128k -c:s webvtt \
    -hls_list_size 0 -movflags +faststart -master_pl_name master.m3u8 \
    -var_stream_map "v:0,a:0,s:0,sgroup:giappone" -hls_playlist_type vod \
    -f hls output.m3u8
