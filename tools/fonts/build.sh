#!/usr/bin/env bash
# Builds assets/fonts/recursive.woff2, the one typeface the site uses, from
# the Recursive variable font (SIL OFL, github.com/arrowtype/recursive).
#
#   ./tools/fonts/build.sh        (or: npm run fonts)
#
# The full font is 2.4 MB with five axes. The site keeps three (MONO for the
# metadata and code, wght, slnt for italics), pins the rest to Linear, and
# keeps Latin only, which comes to about 80 KB. The woff2 is COMMITTED, so
# deploying never runs this. Needs Python with fontTools and brotli; set
# PYTHON if the default one lacks them.
set -euo pipefail
cd "$(dirname "$0")/../.."

VERSION="1.085"
PYTHON="${PYTHON:-python3}"
CACHE="${TMPDIR:-/tmp}/recursive-$VERSION"
VF="$CACHE/ArrowType-Recursive-$VERSION/Recursive_Desktop/Recursive_VF_$VERSION.ttf"

if [ ! -f "$VF" ]; then
  mkdir -p "$CACHE"
  curl -sL -o "$CACHE/recursive.zip" \
    "https://github.com/arrowtype/recursive/releases/download/v$VERSION/ArrowType-Recursive-$VERSION.zip"
  unzip -q -o "$CACHE/recursive.zip" -d "$CACHE"
fi

"$PYTHON" -m fontTools.varLib.instancer "$VF" CASL=0 CRSV=0 wght=300:800 \
  -q -o "$CACHE/instance.ttf"
"$PYTHON" -m fontTools.subset "$CACHE/instance.ttf" \
  --unicodes="U+0020-007E,U+00A0-00FF,U+0131,U+0152-0153,U+2010-2015,U+2018-201E,U+2020-2022,U+2026,U+2032-2033,U+2039-203A,U+20AC,U+20B9,U+2122,U+2190-2193,U+2212,U+2260,U+2264-2265" \
  --layout-features="kern,liga,calt,locl,ccmp,mark,mkmk,tnum,case,zero,ss12" \
  --flavor=woff2 --output-file=assets/fonts/recursive.woff2
echo "wrote assets/fonts/recursive.woff2 ($(wc -c < assets/fonts/recursive.woff2 | tr -d ' ') bytes)"
