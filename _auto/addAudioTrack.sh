#!/bin/zsh
set -e
cd /Users/ashok/Code/apps/leximagine.com/immersive/media

VIDEO=chummanaachy-walkthrough-720p.mp4      # input: the copy the site serves
AUDIO=mixkit-pop-05-695.mp3                   # 2:34 track, looped to fill 4:55
OUT=chummanaachy-walkthrough-720p.with-audio.mp4

DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
FADE_START=$(echo "$DUR - 3" | bc)

ffmpeg -y \
  -i "$VIDEO" \
  -stream_loop -1 -i "$AUDIO" \
  -map 0:v:0 -map 1:a:0 \
  -c:v copy \
  -af "afade=t=out:st=${FADE_START}:d=3" \
  -c:a aac -b:a 128k \
  -t "$DUR" \
  -movflags +faststart \
  "$OUT"

ffprobe -v error -show_entries stream=codec_type,codec_name:format=duration -of default=nw=1 "$OUT"
mv "$OUT" "$VIDEO"
ls -lh "$VIDEO"
