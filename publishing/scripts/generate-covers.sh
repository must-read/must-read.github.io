#!/usr/bin/env bash
# Process raw cover images into ebook, print, and web variants
# Usage: ./publishing/scripts/generate-covers.sh [genre-slug]
# If no genre specified, processes all available raw images
#
# Prerequisites: Raw images in publishing/covers/raw/{genre}.jpg (or .png)
# These should be AI-generated atmospheric images with NO TEXT
#
# Output:
#   publishing/covers/final/ebook/{genre}.jpg      — 1600x2400 with text overlay
#   publishing/covers/final/print-front/{genre}.jpg — 1800x2700 (300dpi 6"x9") with text overlay
#   publishing/covers/final/print-wrap/{genre}.jpg  — full wrap (front+spine+back) for print
#   publishing/covers/final/thumbnail/{genre}.jpg   — 400x600 for web
#
# Compatible with bash 3.2+ (macOS default)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ---------------------------------------------------------------------------
# Directory setup
# ---------------------------------------------------------------------------
RAW_DIR="$PROJECT_ROOT/publishing/covers/raw"
FINAL_DIR="$PROJECT_ROOT/publishing/covers/final"
EBOOK_DIR="$FINAL_DIR/ebook"
PRINT_FRONT_DIR="$FINAL_DIR/print-front"
PRINT_WRAP_DIR="$FINAL_DIR/print-wrap"
THUMB_DIR="$FINAL_DIR/thumbnail"

mkdir -p "$EBOOK_DIR" "$PRINT_FRONT_DIR" "$PRINT_WRAP_DIR" "$THUMB_DIR"

# ---------------------------------------------------------------------------
# All 16 genre slugs
# ---------------------------------------------------------------------------
ALL_GENRES="adventure creative-nonfiction crime-noir dystopian fantasy gothic-fiction historical-fiction horror humor-satire literary-fiction magical-realism mystery-thriller philosophical-fiction romance science-fiction western"

# ---------------------------------------------------------------------------
# Genre metadata lookups (bash 3.2 compatible — no associative arrays)
# ---------------------------------------------------------------------------
genre_display() {
  case "$1" in
    adventure) echo "Adventure" ;;
    creative-nonfiction) echo "Creative Nonfiction" ;;
    crime-noir) echo "Crime Noir" ;;
    dystopian) echo "Dystopian" ;;
    fantasy) echo "Fantasy" ;;
    gothic-fiction) echo "Gothic Fiction" ;;
    historical-fiction) echo "Historical Fiction" ;;
    horror) echo "Horror" ;;
    humor-satire) echo "Humor & Satire" ;;
    literary-fiction) echo "Literary Fiction" ;;
    magical-realism) echo "Magical Realism" ;;
    mystery-thriller) echo "Mystery & Thriller" ;;
    philosophical-fiction) echo "Philosophical Fiction" ;;
    romance) echo "Romance" ;;
    science-fiction) echo "Science Fiction" ;;
    western) echo "Western" ;;
    *) echo "" ;;
  esac
}

genre_volume() {
  case "$1" in
    adventure) echo 1 ;; creative-nonfiction) echo 2 ;; crime-noir) echo 3 ;;
    dystopian) echo 4 ;; fantasy) echo 5 ;; gothic-fiction) echo 6 ;;
    historical-fiction) echo 7 ;; horror) echo 8 ;; humor-satire) echo 9 ;;
    literary-fiction) echo 10 ;; magical-realism) echo 11 ;;
    mystery-thriller) echo 12 ;; philosophical-fiction) echo 13 ;;
    romance) echo 14 ;; science-fiction) echo 15 ;; western) echo 16 ;;
    *) echo 0 ;;
  esac
}

genre_subtitle() {
  case "$1" in
    adventure) echo "Horizons of Salt, Powder, and Unspent Nerve" ;;
    creative-nonfiction) echo "Testimony of the Actual and the Almost True" ;;
    crime-noir) echo "Confessions in Smoke, Neon, and Borrowed Time" ;;
    dystopian) echo "Blueprints of the Permissible and the Erased" ;;
    fantasy) echo "Kingdoms of Ink, Iron, and Impossible Light" ;;
    gothic-fiction) echo "Houses That Remember What the Living Forget" ;;
    historical-fiction) echo "The Weight of Centuries in a Single Room" ;;
    horror) echo "What Watches from the Corner of the Familiar" ;;
    humor-satire) echo "The Precision of Absurdity, Lovingly Applied" ;;
    literary-fiction) echo "Sentences That Know More Than Their Speakers" ;;
    magical-realism) echo "Where the Ordinary Insists on Being Otherwise" ;;
    mystery-thriller) echo "The Architecture of Suspicion and Delayed Truth" ;;
    philosophical-fiction) echo "Premises the Mind Cannot Refuse to Enter" ;;
    romance) echo "The Calculus of Longing and the Algebra of Need" ;;
    science-fiction) echo "Futures Measured in Light-Years and Human Error" ;;
    western) echo "Dust, Distance, and the Morality of Open Ground" ;;
    *) echo "" ;;
  esac
}

genre_pages() {
  case "$1" in
    adventure) echo 300 ;; creative-nonfiction) echo 280 ;; crime-noir) echo 300 ;;
    dystopian) echo 320 ;; fantasy) echo 340 ;; gothic-fiction) echo 300 ;;
    historical-fiction) echo 340 ;; horror) echo 280 ;; humor-satire) echo 260 ;;
    literary-fiction) echo 300 ;; magical-realism) echo 300 ;;
    mystery-thriller) echo 300 ;; philosophical-fiction) echo 320 ;;
    romance) echo 280 ;; science-fiction) echo 320 ;; western) echo 280 ;;
    *) echo 300 ;;
  esac
}

is_valid_genre() {
  local name
  name="$(genre_display "$1")"
  [[ -n "$name" ]]
}

# ---------------------------------------------------------------------------
# Font detection
# ---------------------------------------------------------------------------
detect_font() {
  local style="$1"

  case "$style" in
    regular)
      if magick -list font 2>/dev/null | grep "Font: Baskerville" >/dev/null 2>&1; then
        echo "Baskerville"
      elif magick -list font 2>/dev/null | grep "Font: Times-New-Roman" >/dev/null 2>&1; then
        echo "Times-New-Roman"
      else
        echo "Helvetica"
      fi
      ;;
    bold)
      if magick -list font 2>/dev/null | grep "Font: Baskerville-Bold" >/dev/null 2>&1; then
        echo "Baskerville-Bold"
      elif magick -list font 2>/dev/null | grep "Font: Times-New-Roman-Bold" >/dev/null 2>&1; then
        echo "Times-New-Roman-Bold"
      else
        echo "Helvetica-Bold"
      fi
      ;;
    italic)
      if magick -list font 2>/dev/null | grep "Font: Baskerville-Italic" >/dev/null 2>&1; then
        echo "Baskerville-Italic"
      elif magick -list font 2>/dev/null | grep "Font: Times-New-Roman-Italic" >/dev/null 2>&1; then
        echo "Times-New-Roman-Italic"
      else
        echo "Helvetica-Oblique"
      fi
      ;;
    semibold)
      if magick -list font 2>/dev/null | grep "Font: Baskerville-SemiBold" >/dev/null 2>&1; then
        echo "Baskerville-SemiBold"
      elif magick -list font 2>/dev/null | grep "Font: Times-New-Roman-Bold" >/dev/null 2>&1; then
        echo "Times-New-Roman-Bold"
      else
        echo "Helvetica-Bold"
      fi
      ;;
  esac
}

FONT_REGULAR="$(detect_font regular)"
FONT_BOLD="$(detect_font bold)"
FONT_ITALIC="$(detect_font italic)"
FONT_SEMIBOLD="$(detect_font semibold)"

echo "Using fonts: regular=$FONT_REGULAR bold=$FONT_BOLD italic=$FONT_ITALIC semibold=$FONT_SEMIBOLD"

# ---------------------------------------------------------------------------
# Helper: find raw image for a genre (jpg or png)
# ---------------------------------------------------------------------------
find_raw_image() {
  local genre="$1"
  for ext in jpg jpeg png; do
    local path="$RAW_DIR/$genre.$ext"
    if [[ -f "$path" ]]; then
      echo "$path"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Helper: create gradient overlay (dark at top and bottom for text legibility)
# ---------------------------------------------------------------------------
create_gradient_overlay() {
  local width="$1"
  local height="$2"
  local output="$3"

  # Top gradient: semi-opaque black fading to transparent (top 35%)
  local top_h=$(( height * 35 / 100 ))
  # Bottom gradient: transparent fading to semi-opaque black (bottom 40%)
  local bot_h=$(( height * 40 / 100 ))

  magick -size "${width}x${height}" xc:none \
    \( -size "${width}x${top_h}" gradient:"rgba(0,0,0,0.65)"-"rgba(0,0,0,0)" \) \
      -geometry "+0+0" -composite \
    \( -size "${width}x${bot_h}" gradient:"rgba(0,0,0,0)"-"rgba(0,0,0,0.70)" \) \
      -geometry "+0+$(( height - bot_h ))" -composite \
    "$output"
}

# ---------------------------------------------------------------------------
# Helper: add text overlay to a cover image
# ---------------------------------------------------------------------------
add_text_overlay() {
  local input="$1"
  local output="$2"
  local width="$3"
  local height="$4"
  local genre="$5"
  local scale="$6"  # scaling factor relative to 1600px base (e.g. 1.0, 1.125)

  local display_name
  display_name="$(genre_display "$genre")"
  local volume
  volume="$(genre_volume "$genre")"
  local subtitle
  subtitle="$(genre_subtitle "$genre")"

  # Font sizes scaled from 1600px base
  local sz_series sz_volume sz_genre sz_subtitle sz_tagline
  sz_series=$(printf "%.0f" "$(echo "$scale * 36" | bc)")
  sz_volume=$(printf "%.0f" "$(echo "$scale * 28" | bc)")
  sz_genre=$(printf "%.0f" "$(echo "$scale * 72" | bc)")
  sz_subtitle=$(printf "%.0f" "$(echo "$scale * 30" | bc)")
  sz_tagline=$(printf "%.0f" "$(echo "$scale * 22" | bc)")

  # Vertical positions (percentage of height)
  local y_series=$(( height * 5 / 100 ))
  local y_volume=$(( height * 9 / 100 ))
  local y_genre=$(( height * 78 / 100 ))
  local y_subtitle=$(( height * 84 / 100 ))
  local y_tagline=$(( height * 95 / 100 ))

  magick "$input" \
    -font "$FONT_SEMIBOLD" -pointsize "$sz_series" \
      -fill "rgba(255,255,255,0.95)" \
      -gravity North -annotate "+0+${y_series}" "MUST READ" \
    -font "$FONT_REGULAR" -pointsize "$sz_volume" \
      -fill "rgba(255,255,255,0.75)" \
      -gravity North -annotate "+0+${y_volume}" "Volume ${volume} of 16" \
    -font "$FONT_BOLD" -pointsize "$sz_genre" \
      -fill "rgba(255,255,255,0.95)" \
      -gravity North -annotate "+0+${y_genre}" "$display_name" \
    -font "$FONT_ITALIC" -pointsize "$sz_subtitle" \
      -fill "rgba(255,255,255,0.85)" \
      -gravity North -annotate "+0+${y_subtitle}" "$subtitle" \
    -font "$FONT_ITALIC" -pointsize "$sz_tagline" \
      -fill "rgba(255,255,255,0.55)" \
      -gravity North -annotate "+0+${y_tagline}" "Artificium Inter Legere" \
    "$output"
}

# ---------------------------------------------------------------------------
# Process a single genre
# ---------------------------------------------------------------------------
process_genre() {
  local genre="$1"

  if ! is_valid_genre "$genre"; then
    echo "ERROR: Unknown genre '$genre'"
    return 1
  fi

  local raw_path
  if ! raw_path="$(find_raw_image "$genre")"; then
    echo "SKIP: No raw image found for '$genre' in $RAW_DIR/"
    return 1
  fi

  local display_name
  display_name="$(genre_display "$genre")"
  echo ""
  echo "=========================================="
  echo "  Processing: $display_name ($genre)"
  echo "  Source: $raw_path"
  echo "=========================================="

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  # ------------------------------------------------------------------
  # Step 1: Center crop to 2:3 aspect ratio, trim 2% edges (watermarks)
  # ------------------------------------------------------------------
  echo "  [1/6] Cropping to 2:3 aspect ratio..."

  # Get source dimensions
  local src_dims src_w src_h
  src_dims="$(magick identify -format '%w %h' "$raw_path")"
  src_w="$(echo "$src_dims" | awk '{print $1}')"
  src_h="$(echo "$src_dims" | awk '{print $2}')"

  # Trim 2% from each edge to remove potential watermarks
  local trim_x=$(( src_w * 2 / 100 ))
  local trim_y=$(( src_h * 2 / 100 ))
  local trimmed_w=$(( src_w - 2 * trim_x ))
  local trimmed_h=$(( src_h - 2 * trim_y ))

  magick "$raw_path" \
    -crop "${trimmed_w}x${trimmed_h}+${trim_x}+${trim_y}" +repage \
    "$tmp_dir/trimmed.png"

  # Re-read dimensions after trim
  src_dims="$(magick identify -format '%w %h' "$tmp_dir/trimmed.png")"
  src_w="$(echo "$src_dims" | awk '{print $1}')"
  src_h="$(echo "$src_dims" | awk '{print $2}')"

  # Calculate crop dimensions maintaining 2:3
  local crop_w crop_h
  if (( src_w * 3 > src_h * 2 )); then
    # Image is wider than 2:3 — constrain by height
    crop_h=$src_h
    crop_w=$(( src_h * 2 / 3 ))
  else
    # Image is taller than 2:3 — constrain by width
    crop_w=$src_w
    crop_h=$(( src_w * 3 / 2 ))
  fi

  local offset_x=$(( (src_w - crop_w) / 2 ))
  local offset_y=$(( (src_h - crop_h) / 2 ))

  magick "$tmp_dir/trimmed.png" \
    -crop "${crop_w}x${crop_h}+${offset_x}+${offset_y}" +repage \
    "$tmp_dir/cropped.png"

  # ------------------------------------------------------------------
  # Step 2: Ebook cover (1600x2400)
  # ------------------------------------------------------------------
  echo "  [2/6] Creating ebook cover (1600x2400)..."

  magick "$tmp_dir/cropped.png" \
    -resize "1600x2400^" \
    -gravity Center -extent 1600x2400 \
    "$tmp_dir/ebook_base.png"

  # Apply gradient overlay
  create_gradient_overlay 1600 2400 "$tmp_dir/gradient_ebook.png"

  magick "$tmp_dir/ebook_base.png" \
    "$tmp_dir/gradient_ebook.png" \
    -composite \
    "$tmp_dir/ebook_grad.png"

  # Add text overlay
  add_text_overlay "$tmp_dir/ebook_grad.png" "$EBOOK_DIR/$genre.jpg" 1600 2400 "$genre" 1.0

  echo "    -> $EBOOK_DIR/$genre.jpg"

  # ------------------------------------------------------------------
  # Step 3: Print front cover (1800x2700, 300 DPI)
  # ------------------------------------------------------------------
  echo "  [3/6] Creating print front cover (1800x2700, 300dpi)..."

  magick "$tmp_dir/cropped.png" \
    -resize "1800x2700^" \
    -gravity Center -extent 1800x2700 \
    "$tmp_dir/print_base.png"

  # Apply gradient overlay
  create_gradient_overlay 1800 2700 "$tmp_dir/gradient_print.png"

  magick "$tmp_dir/print_base.png" \
    "$tmp_dir/gradient_print.png" \
    -composite \
    "$tmp_dir/print_grad.png"

  # Add text overlay (scale = 1800/1600 = 1.125)
  add_text_overlay "$tmp_dir/print_grad.png" "$tmp_dir/print_front.png" 1800 2700 "$genre" 1.125

  # Set DPI to 300
  magick "$tmp_dir/print_front.png" -density 300 -units PixelsPerInch \
    "$PRINT_FRONT_DIR/$genre.jpg"

  echo "    -> $PRINT_FRONT_DIR/$genre.jpg"

  # ------------------------------------------------------------------
  # Step 4: Print wrap (back + spine + front)
  # ------------------------------------------------------------------
  echo "  [4/6] Creating print wrap cover..."

  local page_count
  page_count="$(genre_pages "$genre")"
  # Spine width = page_count * 0.002252 inches * 300 DPI = page_count * 0.6756
  local spine_px
  spine_px=$(printf "%.0f" "$(echo "$page_count * 0.6756" | bc)")
  local total_w=$(( 1800 + spine_px + 1800 ))

  local subtitle
  subtitle="$(genre_subtitle "$genre")"
  local display_name_local
  display_name_local="$(genre_display "$genre")"

  # Create back cover: solid dark background with blurb text
  magick -size "1800x2700" "xc:#1C1410" \
    -font "$FONT_REGULAR" -pointsize 32 \
      -fill "rgba(255,255,255,0.80)" \
      -gravity Center -annotate "+0-200" \
        "Must Read is a collection of original short fiction\nspanning sixteen genres, each work born from a unique\nfour-element literary formula. Every story blends the\nstyles of two authors with the structure and themes\nof two published works, producing fiction that exists\nnowhere else in the literary landscape." \
    -font "$FONT_ITALIC" -pointsize 26 \
      -fill "rgba(255,255,255,0.60)" \
      -gravity Center -annotate "+0+100" \
        "Artificium Inter Legere" \
    -font "$FONT_SEMIBOLD" -pointsize 28 \
      -fill "rgba(255,255,255,0.70)" \
      -gravity South -annotate "+0+80" \
        "must-read.github.io" \
    "$tmp_dir/back_cover.png"

  # Create spine: genre name rotated, "Must Read" at bottom
  magick -size "${spine_px}x2700" "xc:#1C1410" \
    -font "$FONT_SEMIBOLD" -pointsize 24 \
      -fill "rgba(255,255,255,0.90)" \
      -gravity Center -annotate "90x90+0-200" "$display_name_local" \
    -font "$FONT_REGULAR" -pointsize 18 \
      -fill "rgba(255,255,255,0.70)" \
      -gravity South -annotate "90x90+0+40" "MUST READ" \
    "$tmp_dir/spine.png"

  # Composite: back + spine + front
  magick "$tmp_dir/back_cover.png" "$tmp_dir/spine.png" "$PRINT_FRONT_DIR/$genre.jpg" \
    +append \
    -density 300 -units PixelsPerInch \
    "$PRINT_WRAP_DIR/$genre.jpg"

  echo "    -> $PRINT_WRAP_DIR/$genre.jpg (spine: ${spine_px}px for ${page_count} pages)"

  # ------------------------------------------------------------------
  # Step 5: Thumbnail (400x600)
  # ------------------------------------------------------------------
  echo "  [5/6] Creating thumbnail (400x600)..."

  magick "$EBOOK_DIR/$genre.jpg" \
    -resize "400x600" \
    -sharpen "0x0.5" \
    "$THUMB_DIR/$genre.jpg"

  echo "    -> $THUMB_DIR/$genre.jpg"

  # ------------------------------------------------------------------
  # Step 6: Summary
  # ------------------------------------------------------------------
  echo "  [6/6] Done: $display_name"
  echo "    ebook:       $(du -h "$EBOOK_DIR/$genre.jpg" | cut -f1)"
  echo "    print-front: $(du -h "$PRINT_FRONT_DIR/$genre.jpg" | cut -f1)"
  echo "    print-wrap:  $(du -h "$PRINT_WRAP_DIR/$genre.jpg" | cut -f1)"
  echo "    thumbnail:   $(du -h "$THUMB_DIR/$genre.jpg" | cut -f1)"

  # Clean up temp directory
  rm -rf "$tmp_dir"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "Must Read — Cover Art Processing Pipeline"
echo "ImageMagick: $(magick --version 2>/dev/null | head -1)"
echo ""

if [[ $# -gt 0 ]]; then
  # Process specific genre(s)
  for genre in "$@"; do
    process_genre "$genre"
  done
else
  # Process all genres that have raw images
  processed=0
  skipped=0
  for genre in $ALL_GENRES; do
    if find_raw_image "$genre" > /dev/null 2>&1; then
      process_genre "$genre"
      processed=$(( processed + 1 ))
    else
      skipped=$(( skipped + 1 ))
    fi
  done

  echo ""
  echo "=========================================="
  echo "  Complete: $processed processed, $skipped skipped (no raw image)"
  echo "=========================================="

  if [[ $skipped -gt 0 ]]; then
    echo ""
    echo "  Missing raw images for:"
    for genre in $ALL_GENRES; do
      if ! find_raw_image "$genre" > /dev/null 2>&1; then
        echo "    - $genre"
      fi
    done
    echo ""
    echo "  Place raw images in: $RAW_DIR/{genre}.jpg"
  fi
fi
