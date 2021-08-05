# M3U8 with WebVTT subtitles

- master playlist: `https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/master.m3u8`
- video/audio playlist: `https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/output.m3u8`
- subtitle playlist: `https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/output_vtt.m3u8`

# yt-dlp output

```
$ yt-dlp -F --list-subs https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/master.m3u8
[generic] master: Requesting header
[redirect] Following redirect to https://raw.githubusercontent.com/ytdl-patched/m3u8_subtitle_test/master/media/master.m3u8
[generic] master: Requesting header
WARNING: [generic] Falling back on generic information extractor.
[generic] master: Downloading webpage
[generic] master: Downloading m3u8 information
[info] Available formats for master:
ID  EXT RESOLUTION |   TBR PROTO  | VCODEC        VBR ACODEC     ABR
--- --- ---------- - ----- ------ - ----------- ----- --------- ----
140 mp4 640x360    |  140k m3u8_n | avc1.64001e  140k mp4a.40.2   0k
Available subtitles for master:
Language Formats
und      vtt
```

# ffprobe output

```
$ ffprobe https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/master.m3u8
ffprobe version 4.3.1-4ubuntu1 Copyright (c) 2007-2020 the FFmpeg developers
  built with gcc 10 (Ubuntu 10.2.0-9ubuntu2)
  configuration: --prefix=/usr --extra-version=4ubuntu1 --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --arch=amd64 --enable-gpl --disable-stripping --enable-avresample --disable-filter=resample --enable-gnutls --enable-ladspa --enable-libaom --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libcodec2 --enable-libdav1d --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libjack --enable-libmp3lame --enable-libmysofa --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librabbitmq --enable-librsvg --enable-librubberband --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libsrt --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvidstab --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-lv2 --enable-omx --enable-openal --enable-opencl --enable-opengl --enable-sdl2 --enable-pocketsphinx --enable-libmfx --enable-libdc1394 --enable-libdrm --enable-libiec61883 --enable-nvenc --enable-chromaprint --enable-frei0r --enable-libx264 --enable-shared
  libavutil      56. 51.100 / 56. 51.100
  libavcodec     58. 91.100 / 58. 91.100
  libavformat    58. 45.100 / 58. 45.100
  libavdevice    58. 10.100 / 58. 10.100
  libavfilter     7. 85.100 /  7. 85.100
  libavresample   4.  0.  0 /  4.  0.  0
  libswscale      5.  7.100 /  5.  7.100
  libswresample   3.  7.100 /  3.  7.100
  libpostproc    55.  7.100 / 55.  7.100
[hls @ 0x560767c28880] Skip ('#EXT-X-VERSION:3')
[hls @ 0x560767c28880] Can't support the subtitle(uri: output_vtt.m3u8)
[hls @ 0x560767c28880] Opening 'https://raw.githubusercontent.com/ytdl-patched/m3u8_subtitle_test/master/media/output.m3u8' for reading
[hls @ 0x560767c28880] Skip ('#EXT-X-VERSION:3')
[hls @ 0x560767c28880] Opening 'https://raw.githubusercontent.com/ytdl-patched/m3u8_subtitle_test/master/media/output0.ts' for reading
[hls @ 0x560767c28880] Opening 'https://raw.githubusercontent.com/ytdl-patched/m3u8_subtitle_test/master/media/output1.ts' for reading
Input #0, hls, from 'https://github.com/ytdl-patched/m3u8_subtitle_test/raw/master/media/master.m3u8':
  Duration: 00:06:03.93, start: 1.443444, bitrate: 0 kb/s
  Program 0 
    Metadata:
      variant_bitrate : 140800
    Stream #0:0: Video: h264 (High) ([27][0][0][0] / 0x001B), yuv420p, 640x360 [SAR 1:1 DAR 16:9], 30 fps, 30 tbr, 90k tbn, 60 tbc
    Metadata:
      variant_bitrate : 140800
    Stream #0:1: Audio: aac (LC) ([15][0][0][0] / 0x000F), 44100 Hz, stereo, fltp
    Metadata:
      variant_bitrate : 140800
```
