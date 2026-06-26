#!/usr/bin/env bash
# screen-to-reel :: tag.sh — embed share-friendly metadata + faststart, no re-encode.
# (TikTok/Reels strip most of this; it helps on YouTube/Drive and makes the file self-describing.)
# Usage:  tag.sh <in.mp4> <out.mp4> "<title>" "<comment>" ["<author>"]
set -euo pipefail
IN=${1:?in.mp4}; OUT=${2:?out.mp4}; TITLE=${3:?title}; COMMENT=${4:?comment}
AUTHOR=${5:-Oloye. The AI Automation Guy}

ffmpeg -y -i "$IN" -map_metadata -1 \
  -metadata title="$TITLE" -metadata artist="$AUTHOR" -metadata author="$AUTHOR" \
  -metadata comment="$COMMENT" -metadata description="$COMMENT" -metadata genre="Education" \
  -movflags use_metadata_tags+faststart -c copy "$OUT"
echo "✓ $OUT"
