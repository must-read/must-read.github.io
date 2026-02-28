#!/usr/bin/env bash
# Generate placeholder covers for testing (no raw image needed)
# Usage: ./publishing/scripts/generate-placeholder-covers.sh [genre-slug]
# If no genre specified, generates placeholders for all 16 genres
#
# Creates gradient-based placeholder covers with text overlay,
# suitable for testing EPUB/PDF build pipelines before real cover art exists.
#
# Output:
#   publishing/covers/final/ebook/{genre}.jpg      — 1600x2400 placeholder
#   publishing/covers/final/thumbnail/{genre}.jpg   — 400x600 placeholder
#
# Compatible with bash 3.2+ (macOS default)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ---------------------------------------------------------------------------
# Directory setup
# ---------------------------------------------------------------------------
FINAL_DIR="$PROJECT_ROOT/publishing/covers/final"
EBOOK_DIR="$FINAL_DIR/ebook"
THUMB_DIR="$FINAL_DIR/thumbnail"

mkdir -p "$EBOOK_DIR" "$THUMB_DIR"

# ---------------------------------------------------------------------------
# All 16 genre slugs
# ---------------------------------------------------------------------------
ALL_GENRES="adventure creative-nonfiction crime-noir dystopian fantasy gothic-fiction historical-fiction horror humor-satire literary-fiction magical-realism mystery-thriller philosophical-fiction romance science-fiction western"

# ---------------------------------------------------------------------------
# Genre metadata lookups (bash 3.2 compatible)
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

# Accent colors per genre for visual differentiation in placeholders
genre_accent() {
  case "$1" in
    adventure) echo "#8B6914" ;;
    creative-nonfiction) echo "#6B705C" ;;
    crime-noir) echo "#5C4033" ;;
    dystopian) echo "#4A4A4A" ;;
    fantasy) echo "#4B3A6B" ;;
    gothic-fiction) echo "#3B1F2B" ;;
    historical-fiction) echo "#7B5B3A" ;;
    horror) echo "#2D1F1F" ;;
    humor-satire) echo "#6B5B2A" ;;
    literary-fiction) echo "#3A4A5C" ;;
    magical-realism) echo "#4A5B3A" ;;
    mystery-thriller) echo "#2A3A4A" ;;
    philosophical-fiction) echo "#4A3A5C" ;;
    romance) echo "#5C2A3A" ;;
    science-fiction) echo "#2A4A5C" ;;
    western) echo "#6B4A2A" ;;
    *) echo "#3A2A20" ;;
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
# Process a single genre
# ---------------------------------------------------------------------------
process_genre() {
  local genre="$1"

  if ! is_valid_genre "$genre"; then
    echo "ERROR: Unknown genre '$genre'"
    return 1
  fi

  local display_name volume subtitle accent
  display_name="$(genre_display "$genre")"
  volume="$(genre_volume "$genre")"
  subtitle="$(genre_subtitle "$genre")"
  accent="$(genre_accent "$genre")"

  echo "  Generating placeholder: $display_name ($genre)..."

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  local width=1600
  local height=2400

  # ------------------------------------------------------------------
  # Step 1: Create gradient background with noise texture
  # ------------------------------------------------------------------

  # Base gradient: dark espresso top (#1C1410) to warm brown bottom (#3A2A20)
  magick -size "${width}x${height}" \
    gradient:"#1C1410"-"#3A2A20" \
    "$tmp_dir/gradient.png"

  # Create a subtle accent band in the center third
  local band_top=$(( height / 3 ))
  local band_h=$(( height / 3 ))
  magick -size "${width}x${band_h}" "xc:${accent}" \
    -channel A -evaluate set 12% +channel \
    "$tmp_dir/accent_band.png"

  magick "$tmp_dir/gradient.png" \
    "$tmp_dir/accent_band.png" -geometry "+0+${band_top}" \
    -composite \
    "$tmp_dir/with_accent.png"

  # Add subtle noise texture for visual interest
  magick -size "${width}x${height}" xc:gray50 \
    +noise Gaussian \
    -channel A -evaluate set 4% +channel \
    "$tmp_dir/noise.png"

  magick "$tmp_dir/with_accent.png" \
    "$tmp_dir/noise.png" \
    -composite \
    "$tmp_dir/base.png"

  # Add a thin decorative border (subtle inner frame)
  local margin=60
  magick "$tmp_dir/base.png" \
    -fill none -stroke "rgba(184,134,11,0.25)" -strokewidth 1 \
    -draw "rectangle ${margin},${margin} $(( width - margin )),$(( height - margin ))" \
    "$tmp_dir/bordered.png"

  # ------------------------------------------------------------------
  # Step 2: Apply gradient overlay for text legibility
  # ------------------------------------------------------------------

  local top_h=$(( height * 30 / 100 ))
  local bot_h=$(( height * 35 / 100 ))

  magick -size "${width}x${height}" xc:none \
    \( -size "${width}x${top_h}" gradient:"rgba(0,0,0,0.40)"-"rgba(0,0,0,0)" \) \
      -geometry "+0+0" -composite \
    \( -size "${width}x${bot_h}" gradient:"rgba(0,0,0,0)"-"rgba(0,0,0,0.45)" \) \
      -geometry "+0+$(( height - bot_h ))" -composite \
    "$tmp_dir/text_gradient.png"

  magick "$tmp_dir/bordered.png" \
    "$tmp_dir/text_gradient.png" \
    -composite \
    "$tmp_dir/ready.png"

  # ------------------------------------------------------------------
  # Step 3: Add text overlay
  # ------------------------------------------------------------------

  local y_series=$(( height * 5 / 100 ))
  local y_volume=$(( height * 9 / 100 ))
  local y_genre=$(( height * 78 / 100 ))
  local y_subtitle=$(( height * 84 / 100 ))
  local y_tagline=$(( height * 95 / 100 ))

  magick "$tmp_dir/ready.png" \
    -font "$FONT_SEMIBOLD" -pointsize 36 \
      -fill "rgba(255,255,255,0.95)" \
      -gravity North -annotate "+0+${y_series}" "MUST READ" \
    -font "$FONT_REGULAR" -pointsize 28 \
      -fill "rgba(255,255,255,0.75)" \
      -gravity North -annotate "+0+${y_volume}" "Volume ${volume} of 16" \
    -font "$FONT_BOLD" -pointsize 72 \
      -fill "rgba(255,255,255,0.95)" \
      -gravity North -annotate "+0+${y_genre}" "$display_name" \
    -font "$FONT_ITALIC" -pointsize 30 \
      -fill "rgba(255,255,255,0.85)" \
      -gravity North -annotate "+0+${y_subtitle}" "$subtitle" \
    -font "$FONT_ITALIC" -pointsize 22 \
      -fill "rgba(255,255,255,0.55)" \
      -gravity North -annotate "+0+${y_tagline}" "Artificium Inter Legere" \
    -quality 92 \
    "$EBOOK_DIR/$genre.jpg"

  echo "    -> $EBOOK_DIR/$genre.jpg"

  # ------------------------------------------------------------------
  # Step 4: Create thumbnail
  # ------------------------------------------------------------------

  magick "$EBOOK_DIR/$genre.jpg" \
    -resize "400x600" \
    -sharpen "0x0.5" \
    -quality 90 \
    "$THUMB_DIR/$genre.jpg"

  echo "    -> $THUMB_DIR/$genre.jpg"

  # Clean up temp directory
  rm -rf "$tmp_dir"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "Must Read — Placeholder Cover Generator"
echo "ImageMagick: $(magick --version 2>/dev/null | head -1)"
echo ""

if [[ $# -gt 0 ]]; then
  # Process specific genre(s)
  for genre in "$@"; do
    process_genre "$genre"
  done
else
  # Process all genres
  count=0
  for genre in $ALL_GENRES; do
    process_genre "$genre"
    count=$(( count + 1 ))
  done

  echo ""
  echo "=========================================="
  echo "  Generated $count placeholder covers"
  echo "  Ebook:     $EBOOK_DIR/"
  echo "  Thumbnail: $THUMB_DIR/"
  echo "=========================================="
fi
