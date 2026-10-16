#!/bin/zsh
# Build the Backdropsource walkthrough for the Immersive Shopping page.
#
#   1. Join two clips in order: the eagle surveillance flyover, then the
#      low drone hover. They differ in size (1280x720 and 960x540), so both
#      are scaled to 1280x720 first so the second half doesn't jump.
#   2. Convert their full-range colour (yuvj420p) to standard web range, so
#      browsers don't show it washed out.
#   3. Add the music as the only audio track (neither clip has sound): short
#      fade in, fade out over the last 3 s, trimmed to the video's length.
#      The music loops if it is ever shorter than the video.
#
# Usage:  zsh _auto/backdropsourceVideo.sh
# Output: immersive/media/backdropsource-walkthrough-720p.mp4
set -e
cd "${0:A:h}/../immersive/media"

CLIP1=eagle-surveillance-1min-small.mp4
CLIP2=drone-low-hover-cards-1min-small.mp4
MUSIC=mixkit-see-line-funk-105.mp3
OUT=${OUT:-backdropsource-walkthrough-720p.mp4}

MUSIC_VOL=0.8
END_FADE=3

calc() { awk "BEGIN{printf \"%.3f\", $1}"; }
dur()  { ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"; }

DUR=$(calc "$(dur $CLIP1) + $(dur $CLIP2)")
echo "joining ${CLIP1} + ${CLIP2} -> ${DUR}s"

NORM="scale=1280:720:flags=lanczos:in_range=full:out_range=limited,setsar=1,fps=30,format=yuv420p"

ffmpeg -y -v error -stats \
  -i "$CLIP1" \
  -i "$CLIP2" \
  -stream_loop -1 -i "$MUSIC" \
  -filter_complex "
    [0:v]${NORM}[v1];
    [1:v]${NORM}[v2];
    [v1][v2]concat=n=2:v=1:a=0[v];
    [2:a]aformat=sample_rates=48000:channel_layouts=stereo,volume=${MUSIC_VOL},
         atrim=start=0:end=${DUR},asetpts=PTS-STARTPTS,
         afade=t=in:st=0:d=0.5,afade=t=out:st=$(calc "$DUR - $END_FADE"):d=${END_FADE}[a]" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -preset slow -crf 28 -profile:v high \
  -c:a aac -b:a 128k \
  -t "$DUR" -movflags +faststart \
  "$OUT"

echo "--- check ---"
ffprobe -v error -show_entries stream=codec_type,codec_name,width,height,pix_fmt:format=duration -of compact=p=0 "$OUT"
ls -lh "$OUT"
