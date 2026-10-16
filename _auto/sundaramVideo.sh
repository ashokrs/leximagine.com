#!/bin/zsh
# Build the Sundaram Pottery walkthrough for the Immersive Shopping page.
#
#   1. Cut the fade-in from black at the start (measured: luma climbs from
#      black to full brightness over the first 0.6 s, then holds flat).
#   2. Keep the recording's own audio ONLY for the user <-> Sundari conversation
#      (measured: speech from 44.4 s to 59.6 s of the original; padded below).
#   3. Lay the music under everything else: it plays from the first frame,
#      fades out just before the conversation, stays silent while they talk,
#      then resumes from where it paused and fades out at the end.
#      The music loops if it is ever shorter than needed.
#   4. Scale 1600x900 -> 1280x720 and encode for the web (faststart).
#
# Usage:  zsh _auto/sundaramVideo.sh
# Output: immersive/media/sundarampottery-walkthrough-720p.mp4
set -e
cd "${0:A:h}/../immersive/media"

SRC=SundaramPottery-desktop-walkthrough.mp4
MUSIC=mixkit-thinking-about-you-234.mp3
OUT=${OUT:-sundarampottery-walkthrough-720p.mp4}

TRIM=0.6            # seconds of fade-in to remove
CONV_START=44.2     # conversation start in the ORIGINAL video (speech at 44.4)
CONV_END=59.9       # conversation end   in the ORIGINAL video (speech to 59.6)
MUSIC_VOL=0.6       # music level; sits just under the voices
GAP_FADE=0.8        # music fade out/in around the conversation
END_FADE=3          # music fade at the very end

calc() { awk "BEGIN{printf \"%.3f\", $1}"; }

SRC_DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$SRC")
DUR=$(calc "$SRC_DUR - $TRIM")                 # length after the trim
CS=$(calc "$CONV_START - $TRIM")               # conversation start, new timeline
CE=$(calc "$CONV_END - $TRIM")                 # conversation end,   new timeline
REST=$(calc "$DUR - $CE")                      # music needed after the conversation
CS_MS=$(calc "$CS * 1000"); CE_MS=$(calc "$CE * 1000")

echo "trim ${TRIM}s | output ${DUR}s | conversation ${CS}s -> ${CE}s | music resumes for ${REST}s"

ffmpeg -y -v error -stats \
  -ss "$TRIM" -i "$SRC" \
  -stream_loop -1 -i "$MUSIC" \
  -filter_complex "
    [0:v]scale=1280:720:flags=lanczos,setsar=1,format=yuv420p[v];
    [0:a]aformat=sample_rates=48000:channel_layouts=stereo,
         atrim=start=${CS}:end=${CE},
         afade=t=in:st=${CS}:d=0.15,afade=t=out:st=$(calc "$CE - 0.15"):d=0.15,
         asetpts=PTS-STARTPTS,adelay=delays=${CS_MS}:all=1[conv];
    [1:a]aformat=sample_rates=48000:channel_layouts=stereo,volume=${MUSIC_VOL},asplit=2[m1][m2];
    [m1]atrim=start=0:end=${CS},asetpts=PTS-STARTPTS,
         afade=t=out:st=$(calc "$CS - $GAP_FADE"):d=${GAP_FADE}[before];
    [m2]atrim=start=${CS}:end=$(calc "$CS + $REST"),asetpts=PTS-STARTPTS,
         afade=t=in:st=0:d=${GAP_FADE},afade=t=out:st=$(calc "$REST - $END_FADE"):d=${END_FADE},
         adelay=delays=${CE_MS}:all=1[after];
    [before][after][conv]amix=inputs=3:normalize=0:duration=longest[a]" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -preset medium -crf 26 -profile:v high \
  -c:a aac -b:a 128k \
  -t "$DUR" -movflags +faststart \
  "$OUT"

echo "--- check ---"
ffprobe -v error -show_entries stream=codec_type,codec_name,width,height:format=duration -of compact=p=0 "$OUT"
FIRST=$(ffprobe -v error -f lavfi "movie=$OUT,signalstats" -read_intervals "%+#1" \
        -show_entries frame_tags=lavfi.signalstats.YAVG -of csv=p=0 | head -1)
echo "first-frame brightness: $FIRST (black is 16; this source is ~167 when fully lit)"
ls -lh "$OUT"
