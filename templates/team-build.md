# Video type: "Team Build"

A repeatable format for Oloye. content. **Your AI team builds a real deliverable live on screen → reveal the finished result → give away the skill that did it.** Same structure every time; swap the *angle* (the hook) and the *subject* (what gets built). Built on the `screen-to-reel` pipeline.

## Why it works
- Proof, not claims: people watch the thing get built.
- The AI team is the differentiator (Ben → Sade → Ada → Theo), so it shows the brand's edge.
- Ends on a giveaway comment-trigger → engagement + lead capture in one move.

## The fixed structure (4 beats, ~30-35s)
1. **Hook (2.5s)** — a scroll-stopping angle + cover. Remotion `Hook` comp.
2. **Build (~20s)** — screen recording of the AI team building, sped up, with branded captions narrating each teammate (briefed → copy → design → build). `caption-bar.sh`.
3. **Reveal (~5-7s)** — scroll-pan over the finished result. `scroll-pan.sh`.
4. **Giveaway end-card (2s)** — "Comment 'WORD' to get the free skill." Remotion `CTAOverlay`.

Then `xfade-stitch.sh` (0.5s dissolves) + `tag.sh`.

## The two things you swap

### Angle (the hook) — `Hook` comp presets in `brand/motion`
| id | lines | accent |
|---|---|---|
| `HookCost` | I stopped / paying for / websites. | my AI team builds them. |
| `HookTime` | A website / in minutes. | not weeks. not thousands. |
| `HookPOV` | POV: your / AI team builds / your website. | you just watch. |
| *Face* (optional) | — | Oloye on camera via `clone-studio`, then cut to the build (strongest stop, builds recognition). |

New angle = add one `<Composition>` with `defaultProps={{ lines:[...], accent:'...' }}`. Keep it one emotion, no em dashes, no fabricated stats.

### Subject (what gets built)
website (done) · landing page · lead magnet · cold-email sequence · a mini automation · a dashboard. The build captions stay team-shaped: `briefed → [agent] → [agent] → [agent builds]`. The end-card word matches the giveaway (`website`, `funnel`, etc.).

## Make one (commands)
```bash
# from the video project folder; fonts in _fonts/ (see ../SKILL.md)
# 1. hook + cover  (pick the angle id)
(cd <motion> && npx remotion render src/index.ts HookCost out/hook.mp4 \
              && npx remotion still  src/index.ts HookCost out/cover.png --frame=58)

# 2. reframe raw recording -> vertical (tune crop/speed), then speed the build for pace
ffmpeg -i raw.mp4 -vf "crop=608:1080:656:0,scale=1080:1920,setpts=PTS/9,fps=30" -an reframed.mp4
ffmpeg -i reframed.mp4 -vf "setpts=PTS/1.8,fps=30" -an -t 22.5 build-fast.mp4   # ~22s keeps it punchy

# 3. branded captions (captions.txt: START|END|TEXT, scaled to the sped clip)
bash scripts/caption-bar.sh build-fast.mp4 build-cap.mp4 captions.txt

# 4. reveal + 5. stitch + 6. tag
bash scripts/scroll-pan.sh page-tall.png reveal.mp4 7
bash scripts/xfade-stitch.sh out.mp4 0.5 hook.mp4 build-cap.mp4 reveal.mp4 endcard.mp4
bash scripts/tag.sh out.mp4 final.mp4 "Title" "Comment 'word' for the free skill"
```

## Caption beats (website subject, ~22s sped build)
```
0|5.5|I briefed my AI team
5.5|12.2|Sade writes the copy
12.2|18.3|Ada designs it
18.3|23|Theo builds the site
```
Re-time for other subjects/speeds; keep them in sync with the on-screen action.

## Post-with kit (always hand this back)
- **Caption** ending on the comment trigger (e.g. *Comment "website" and I'll send the free skill*).
- **~6 relevant hashtags**, the **cover** (the hook frame), and a **pinned comment** restating the CTA. Reply to every trigger comment (sends the freebie + spikes comments).

## Reference build
First Team Build: `Business/90-Day Awareness Campaign/videos/whatsapp-website-build/` (angle: Cost, subject: website, giveaway: `site-builder` skill via "Comment 'website'"). Final: `output/whatsapp-v6-final.mp4` (~32s).
