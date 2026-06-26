# screen-to-reel

Turn a raw screen recording (or any landscape clip) into a post-ready, on-brand **9:16 vertical reel** for TikTok / Reels / Shorts / WhatsApp Status.

It reframes to vertical, burns **readable branded captions** (solid bar + accent hairline + accent dot + wordmark), builds an optional **scroll-pan reveal**, appends a **CTA end-card**, **crossfade-stitches** the pieces, and embeds share metadata — then hands you the caption, hashtags and cover guidance to post with.

This is a **Claude skill**: drop it in `~/.claude/skills/screen-to-reel/` and Claude Code drives the pipeline for you. The scripts also run standalone.

## Requirements
- `ffmpeg` + `ffprobe` on PATH
- bash (Git Bash on Windows is fine)
- A display TTF (Space Grotesk by default — fetch command in `SKILL.md`) and any TTF with the `●` glyph

## Quick start
```bash
# 1. fonts (once)
mkdir -p _fonts
curl -sL "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf" -o _fonts/sg.ttf
cp /c/Windows/Fonts/arial.ttf _fonts/dot.ttf   # or any TTF with ●

# 2. reframe landscape -> vertical (tune crop/speed to your clip)
ffmpeg -i raw.mp4 -vf "crop=608:1080:656:0,scale=1080:1920,setpts=PTS/9,fps=30" -an reframed.mp4

# 3. branded captions (edit captions.txt: START|END|TEXT per line)
bash scripts/caption-bar.sh reframed.mp4 captioned.mp4 captions.txt

# 4. optional reveal from a full-page screenshot
bash scripts/scroll-pan.sh page-tall.png reveal.mp4 7

# 5. crossfade-stitch + 6. tag
bash scripts/xfade-stitch.sh stitched.mp4 1 captioned.mp4 reveal.mp4 endcard.mp4
bash scripts/tag.sh stitched.mp4 final.mp4 "My title" "Comment 'word' for the freebie"
```

## Brand it
Everything retargets via env vars — see `examples/brand.conf.example` (`ACCENT`, `BASE`, `TEXTCOL`, `FONT`, `WORDMARK`).

## Scripts
| Script | Does |
|---|---|
| `caption-bar.sh` | Top wordmark bar + bottom caption bar (accent hairline + accent dot + timed white captions). The signature look. |
| `scroll-pan.sh` | Pan over a tall screenshot to reveal a finished result. |
| `xfade-stitch.sh` | Crossfade-concat any number of 9:16 clips (auto offsets). |
| `tag.sh` | Embed metadata + faststart (no re-encode). |

## License
MIT — see `LICENSE`. Built by **Oloye. The AI Automation Guy.**
