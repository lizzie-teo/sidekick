#!/usr/bin/env bash
# Turn a green-screen clip into an animated WebP with real transparency.
#
#   tools/greenscreen_to_webp.sh assets/_source/clip.mp4 assets/images/sidekick.webp
#
# Needs: brew install ffmpeg webp
#
# The green is keyed in YUV (chromakey, not colorkey -- video green varies
# frame to frame, and YUV separates colour from brightness so black shoes and
# dark hair survive).
#
# Two things this deliberately does NOT do, both tried and both wrong:
#
#   despill      pulls green out of the whole picture, not just the edge, and
#                turns the cream sweater magenta.
#   erosion      shaves a pixel off the edge to kill the dark rim h264 leaves,
#                and leaves a pale rim instead, which is worse on a light
#                background. The rim is unfixable anyway: h264 stores colour at
#                half resolution, so edge pixels have the character's colour
#                and the green already averaged into one value.
#
# Scaling is also left out. The character is drawn with thin dark linework and
# shrinking it washes that out. 480x720 is small enough.
set -euo pipefail

IN="${1:?usage: greenscreen_to_webp.sh <in.mp4> <out.webp>}"
OUT="${2:?usage: greenscreen_to_webp.sh <in.mp4> <out.webp>}"

# The character's box in the source, and the frame rate to keep. 24 is the
# source rate; anything less makes the breathing step rather than flow.
CROP="${CROP:-480:720:416:0}"
FPS="${FPS:-24}"
GREEN="${GREEN:-0x2BBB0F}"
QUALITY="${QUALITY:-85}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

ffmpeg -v error -y -i "$IN" \
  -vf "crop=$CROP,chromakey=$GREEN:0.13:0.06,fps=$FPS" \
  -pix_fmt rgba "$WORK/f%04d.png"

# WebP frame durations are milliseconds, so the delay is 1000 / fps.
DELAY=$(( 1000 / FPS ))
img2webp -loop 0 -d "$DELAY" -lossy -q "$QUALITY" -m 6 \
  $(ls "$WORK"/f*.png | sort) -o "$OUT"

ls -lh "$OUT"
