#!/usr/bin/env bash
# screen-to-reel :: scroll-pan.sh — pan over a tall screenshot to make a "reveal" clip.
# Usage:  scroll-pan.sh <tall.png> <out.mp4> <seconds>
# Produces 1080x1920 @ 30fps, panning top -> bottom over <seconds>.
# Tip: end on the last real content (crop the screenshot) so there's no blank scroll at the tail.
set -euo pipefail
IN=${1:?tall.png}; OUT=${2:?out.mp4}; DUR=${3:?seconds}

ffmpeg -y -loop 1 -t "$DUR" -i "$IN" \
  -vf "scale=1080:-2,crop=1080:1920:0:'min(max((ih-1920)*t/${DUR}\,0)\,ih-1920)',fps=30,format=yuv420p" \
  -c:v libx264 -crf 18 -preset medium "$OUT"
echo "✓ $OUT"
