#!/usr/bin/env bash
# Renders tools/cover/cover.html to assets/og-cover.png (1200x630), the image
# shown when a link to the site is shared. Needs Google Chrome.
set -euo pipefail
cd "$(dirname "$0")/../.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files --virtual-time-budget=2000 --no-first-run \
  --window-size=1200,630 --screenshot="$PWD/assets/og-cover.png" \
  "file://$PWD/tools/cover/cover.html" >/dev/null 2>&1
echo "wrote assets/og-cover.png"
