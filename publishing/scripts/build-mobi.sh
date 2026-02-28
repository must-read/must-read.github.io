#!/usr/bin/env bash
# Convert EPUB files to MOBI format using Calibre's ebook-convert
# Usage: ./publishing/scripts/build-mobi.sh [genre-slug]
# If no genre specified, converts all available EPUBs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EPUB_DIR="$PROJECT_ROOT/publishing/output/epub"
MOBI_DIR="$PROJECT_ROOT/publishing/output/mobi"
EBOOK_CONVERT="/Applications/calibre.app/Contents/MacOS/ebook-convert"

# Check calibre
if [[ ! -x "$EBOOK_CONVERT" ]]; then
  echo "Error: calibre not found at $EBOOK_CONVERT"
  echo "Install with: brew install --cask calibre"
  exit 1
fi

# All genres in volume order
GENRES=(
  adventure creative-nonfiction crime-noir dystopian
  fantasy gothic-fiction historical-fiction horror
  humor-satire literary-fiction magical-realism mystery-thriller
  philosophical-fiction romance science-fiction western
)

# Genre display names
declare -A GENRE_DISPLAY=(
  [adventure]="Adventure"
  [creative-nonfiction]="Creative Nonfiction"
  [crime-noir]="Crime Noir"
  [dystopian]="Dystopian"
  [fantasy]="Fantasy"
  [gothic-fiction]="Gothic Fiction"
  [historical-fiction]="Historical Fiction"
  [horror]="Horror"
  [humor-satire]="Humor & Satire"
  [literary-fiction]="Literary Fiction"
  [magical-realism]="Magical Realism"
  [mystery-thriller]="Mystery & Thriller"
  [philosophical-fiction]="Philosophical Fiction"
  [romance]="Romance"
  [science-fiction]="Science Fiction"
  [western]="Western"
)

convert_genre() {
  local genre="$1"
  local epub="$EPUB_DIR/${genre}.epub"
  local mobi="$MOBI_DIR/${genre}.mobi"

  if [[ ! -f "$epub" ]]; then
    echo "  SKIP: No EPUB found for ${GENRE_DISPLAY[$genre]}"
    return 0
  fi

  echo "  Converting ${GENRE_DISPLAY[$genre]}..."
  "$EBOOK_CONVERT" "$epub" "$mobi" \
    --output-profile kindle_pw3 \
    --mobi-file-type both \
    --no-inline-toc \
    --pretty-print \
    2>/dev/null

  if [[ -f "$mobi" ]]; then
    local size
    size=$(du -h "$mobi" | cut -f1)
    echo "    OK: $mobi ($size)"
  else
    echo "    FAIL: Conversion failed for $genre"
    return 1
  fi
}

echo "=== Must Read — MOBI Conversion ==="
echo ""

mkdir -p "$MOBI_DIR"

if [[ $# -gt 0 ]]; then
  # Convert specific genre
  convert_genre "$1"
else
  # Convert all
  success=0
  fail=0
  skip=0
  for genre in "${GENRES[@]}"; do
    if [[ -f "$EPUB_DIR/${genre}.epub" ]]; then
      if convert_genre "$genre"; then
        ((success++))
      else
        ((fail++))
      fi
    else
      ((skip++))
    fi
  done
  echo ""
  echo "Done: $success converted, $skip skipped, $fail failed"
fi
