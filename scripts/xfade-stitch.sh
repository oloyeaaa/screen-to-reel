#!/usr/bin/env bash
# screen-to-reel :: xfade-stitch.sh — crossfade-concat any number of 9:16 clips.
# Usage:  xfade-stitch.sh <out.mp4> <xfadeSecs> <clip1> <clip2> [clip3 ...]
# Pass clips already trimmed to the length you want; this dissolves whatever it is given.
set -euo pipefail
OUT=${1:?out.mp4}; XF=${2:?xfade seconds}; shift 2
CLIPS=("$@")
n=${#CLIPS[@]}
[ "$n" -ge 2 ] || { echo "need >=2 clips"; exit 1; }

args=(); filt=""; durs=()
for i in "${!CLIPS[@]}"; do
  args+=(-i "${CLIPS[$i]}")
  filt+="[${i}:v]fps=30,format=yuv420p,settb=AVTB,setpts=PTS-STARTPTS[v${i}];"
  d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "${CLIPS[$i]}")
  durs+=("$d")
done

prev="v0"; total="${durs[0]}"
for ((i=1;i<n;i++)); do
  off=$(awk "BEGIN{printf \"%.3f\", ${total}-${XF}}")
  filt+="[${prev}][v${i}]xfade=transition=fade:duration=${XF}:offset=${off}[x${i}];"
  prev="x${i}"
  total=$(awk "BEGIN{printf \"%.3f\", ${total}+${durs[$i]}-${XF}}")
done
filt="${filt%;}"

ffmpeg -y "${args[@]}" -filter_complex "$filt" -map "[${prev}]" -an \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -preset medium "$OUT"
echo "✓ $OUT  (~${total}s)"
