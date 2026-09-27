#!/usr/bin/env bash
# Typeset _data/resume.yml into assets/resume.pdf, then prove it is still
# readable by a machine.
#
#   ./tools/resume/build.sh        (or: npm run resume)
#
# Run this after editing the resume, look at the PDF, and commit it. The PDF is
# COMMITTED on purpose so the deploy has no resume build step.
# The pre-commit hook rebuilds it automatically when a source file changes, so
# it cannot go stale.
#
# Requires: typst (pinned below) and uv. No other system dependency.

set -euo pipefail
cd "$(dirname "$0")"

TYPST_EXPECTED="0.15.1"

actual="$(typst --version | awk '{print $2}')"
if [ "$actual" != "$TYPST_EXPECTED" ]; then
  echo "warning: typst $actual, expected $TYPST_EXPECTED" >&2
fi

# --root ../.. is the repo root, so resume.typ can read ../../_data/resume.yml.
# --creation-timestamp 0 makes the output reproducible: without it every build
# embeds the current time and no two builds match.
echo "→ compiling assets/resume.pdf"
typst compile \
  --root ../.. \
  --font-path fonts \
  --creation-timestamp 0 \
  resume.typ ../../assets/resume.pdf

echo "→ extraction gates"
uv run --quiet --with-requirements requirements.txt python check.py ../../assets/resume.pdf
