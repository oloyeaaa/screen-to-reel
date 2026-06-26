#!/usr/bin/env bash
# screen-to-reel :: caption-bar.sh
# Burn branded captions onto a 9:16 (1080x1920) clip:
#   - top bar (opaque) hides source chrome + any source captions, carries the wordmark
#   - bottom bar: near-solid panel + accent hairline + accent dot + timed white captions
#
# Usage:  caption-bar.sh <in.mp4> <out.mp4> <captions.txt>
# captions.txt: one beat per line ->  START|END|TEXT   (seconds). Lines starting with # are ignored.
# Brand via env (Oloye. defaults):
#   ACCENT=0xC6F23C  BASE=0x0E0F12  TEXTCOL=0xF5F6F7
#   FONT=_fonts/sg.ttf   DOTFONT=_fonts/dot.ttf   WORDMARK=Oloye  (empty = no wordmark)
set -euo pipefail

IN=${1:?input.mp4}; OUT=${2:?output.mp4}; CAPS=${3:?captions.txt}
ACCENT=${ACCENT:-0xC6F23C}; BASE=${BASE:-0x0E0F12}; TEXTCOL=${TEXTCOL:-0xF5F6F7}
FONT=${FONT:-_fonts/sg.ttf}; DOTFONT=${DOTFONT:-_fonts/dot.ttf}; WORDMARK=${WORDMARK:-Oloye}

FF=$(mktemp)
{
  # top bar hides source browser/app chrome + any source captions
  echo "drawbox=x=0:y=0:w=1080:h=215:color=${BASE}@1:t=fill,"
  # bottom caption panel + accent hairline
  echo "drawbox=x=0:y=1460:w=1080:h=230:color=${BASE}@0.92:t=fill,"
  echo "drawbox=x=0:y=1460:w=1080:h=6:color=${ACCENT}:t=fill,"
  # accent dot leading the caption line
  echo "drawtext=fontfile=${DOTFONT}:text='●':fontcolor=${ACCENT}:fontsize=40:x=86:y=1556,"
  # wordmark in the top bar (white name + accent full-stop)
  if [ -n "$WORDMARK" ]; then
    dotx=$(( 70 + ${#WORDMARK} * 54 * 56 / 100 ))
    echo "drawtext=fontfile=${FONT}:text='${WORDMARK}':fontcolor=${TEXTCOL}:fontsize=54:x=70:y=74,"
    echo "drawtext=fontfile=${FONT}:text='.':fontcolor=${ACCENT}:fontsize=54:x=${dotx}:y=74,"
  fi
  # timed captions
  first=1
  while IFS='|' read -r s e t || [ -n "${s:-}" ]; do
    s=${s%$'\r'}; e=${e%$'\r'}; t=${t%$'\r'}
    [ -z "${s// /}" ] && continue
    case "$s" in \#*) continue;; esac
    t=${t//\'/’}   # swap straight apostrophes so we don't fight filter escaping
    if [ $first -eq 1 ]; then first=0; else echo ","; fi
    printf "drawtext=fontfile=%s:text='%s':fontcolor=%s:fontsize=60:x=150:y=1548:enable='between(t\\,%s\\,%s)'" \
      "$FONT" "$t" "$TEXTCOL" "$s" "$e"
  done < "$CAPS"
  echo
} > "$FF"

ffmpeg -y -i "$IN" -filter_script:v "$FF" -an -c:v libx264 -pix_fmt yuv420p -crf 18 -preset medium "$OUT"
rm -f "$FF"
echo "✓ $OUT"
