---
name: screen-to-reel
description: Turn a raw screen recording (or any landscape clip) into a post-ready, on-brand 9:16 vertical reel for TikTok / Reels / Shorts / WhatsApp Status. Reframes to vertical, burns readable branded captions (solid bar + accent hairline + accent dot + wordmark), builds a scroll-pan reveal, appends a CTA end-card, crossfade-stitches it, and embeds share metadata. Ships caption + hashtags + cover guidance. Use for "turn this recording into a reel/short", "make this screen capture a vertical video", "caption and brand this clip".
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Screen → Reel — a raw recording becomes a post-ready vertical video

Give it a screen recording (or any clip). It returns a polished 9:16 video: reframed, captioned in your brand, with a reveal and a CTA end-card, crossfaded together, metadata embedded, plus the caption and hashtags to post with.

*(A free skill from Oloye. The AI Automation Guy. Want this run for your business? See the end.)*

Tools needed: **ffmpeg** + **ffprobe** on PATH. Helper scripts live in `scripts/`. Brand defaults are Oloye.'s; override via env for any brand.

## When to use
"turn this recording into a reel / short / status", "make this screen capture vertical", "caption and brand this clip", "add a CTA end-card".

## The signature look (what makes it read on a phone)
- **9:16, 1080x1920, 30fps.**
- **Top bar** (opaque) hides the source browser/app chrome and any messy source captions, and carries the **wordmark** (name in white, full-stop in the accent colour).
- **Bottom caption bar**: a near-solid panel with an **accent hairline** on top and an **accent dot** leading each line, white text. Captions are legible over ANY background (this is the fix for "captions you can't read").
- **Accent + base + display font** are the only brand levers. One accent, used sparingly.

Oloye. brand defaults: accent Signal Lime `0xC6F23C`, base `0x0E0F12`, text `0xF5F6F7`, font Space Grotesk, wordmark `Oloye`.

## Brand config (env vars, all optional)
```
ACCENT=0xC6F23C   BASE=0x0E0F12   TEXTCOL=0xF5F6F7
FONT=_fonts/sg.ttf        # display TTF (Space Grotesk by default)
DOTFONT=_fonts/dot.ttf    # any TTF containing ● (Arial/Segoe work)
WORDMARK=Oloye            # trailing accent dot added automatically; empty = none
```
Get the fonts once (Space Grotesk is OFL, safe to use):
```
mkdir -p _fonts
curl -sL "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf" -o _fonts/sg.ttf
cp /c/Windows/Fonts/arial.ttf _fonts/dot.ttf    # or any TTF with the ● glyph
```

## The pipeline (each step is one helper or one command)

### 1. Reframe to vertical (recording-specific — do this by eye)
A landscape recording squeezed into 9:16 looks tiny. Crop a tall strip from the action and scale to fill, speeding up dead time. Example (crop a centre strip, ~9x speed):
```
ffmpeg -i raw.mp4 -vf "crop=608:1080:656:0,scale=1080:1920,setpts=PTS/9,fps=30" -an reframed.mp4
```
Tune `crop=W:H:X:Y` to the part of the screen that matters, and `setpts=PTS/N` to hit your target length. Aim for 30-45s.

### 2. Branded captions  →  `scripts/caption-bar.sh`
Write a captions file, one line per beat: `START|END|TEXT` (seconds). Keep lines short.
```
0|10|I briefed my AI team
10|22|Sade writes the copy
22|33|Ada designs it
33|46|Theo builds the site
```
Then:
```
bash scripts/caption-bar.sh reframed.mp4 captioned.mp4 captions.txt
```
Time captions to what is happening on screen (read frames if unsure: `ffmpeg -ss T -i in.mp4 -frames:v 1 f.png`).

### 3. (Optional) scroll-pan reveal  →  `scripts/scroll-pan.sh`
Show the finished result by panning a full-page screenshot. Take a tall screenshot (e.g. `tools/render.cjs --full`), then:
```
bash scripts/scroll-pan.sh page-tall.png reveal.mp4 7
```
End the pan on the last real content so there is no blank scroll at the tail.

### 4. CTA end-card (2s)
Append a short branded CTA so every video ends on one action. Oloye.'s reusable end-cards are Remotion comps (`brand/motion` → `CTAOverlay` / `CTAOverlaySkill`); any 1080x1920 clip works. Drive ONE action ("Comment 'word'", "DM 'AUDIT'").

### 5. Crossfade-stitch  →  `scripts/xfade-stitch.sh`
Trim each piece to length first, then dissolve them together (1s):
```
bash scripts/xfade-stitch.sh stitched.mp4 1 captioned.mp4 reveal.mp4 endcard.mp4
```
(Pass clips already trimmed to the length you want; the script dissolves whatever it is given.)

### 6. Metadata + faststart  →  `scripts/tag.sh`
```
bash scripts/tag.sh stitched.mp4 final.mp4 "Title here" "Comment 'website' to get the free skill"
```
`faststart` moves the moov atom to the front so playback starts instantly (protects early watch-through).

## What to post with it (this is what actually moves the algorithm)
TikTok/Reels strip most file metadata. Reach is driven by: **caption text** (it OCRs the video too), **hashtags**, the **first 1.5s**, the **cover**, and **early engagement**. So always hand back:
- **Caption**: benefit-led, ends on a comment trigger (e.g. *Comment "website" and I'll send it free*).
- **Hashtags**: ~6 relevant, not 15 random.
- **Cover**: pick a frame showing the payoff + 3-4 word text overlay.
- **Pinned comment**: restate the CTA; reply to every trigger comment (spikes comments = more reach).

## Quality rules
- Captions short and timed to the action. One idea per beat.
- One accent colour only. No em dashes. No fabricated stats, no fake testimonials.
- Keep it 30-45s; open on motion, not a static title.
- Re-encode when crossfading (stream-copy concat breaks on dissimilar clips); `-crf 18`.

## Make it yours
Set `ACCENT`, `BASE`, `FONT`, `WORDMARK` for any brand and the whole look retargets. The structure stays the same.

---
Built by **Oloye. The AI Automation Guy.** Want your content engine set up like this? Comment or DM **'AUDIT'** for a free look.
