#!/usr/bin/env bash
# Build EPUB files from compiled genre markdown
# Usage: ./publishing/scripts/build-epub.sh [genre-slug]
# If no genre specified, builds all 16

set -euo pipefail

# --------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PUB_DIR="$PROJECT_ROOT/publishing"
TEMPLATES_DIR="$PUB_DIR/templates"
COMPILED_DIR="$PUB_DIR/compiled"
METADATA_DIR="$PUB_DIR/metadata"
COVERS_DIR="$PUB_DIR/covers/final/ebook"
OUTPUT_DIR="$PUB_DIR/output/epub"
CSS_FILE="$TEMPLATES_DIR/epub.css"

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

log_info() { echo "[epub] $*"; }
log_ok()   { echo "[epub] OK: $*"; }
log_err()  { echo "[epub] ERROR: $*" >&2; }

# Extract a YAML field value from a metadata file (simple grep/sed approach)
yaml_field() {
  local file="$1" field="$2"
  sed -n "s/^${field}: *//p" "$file" | sed 's/^ *"//;s/" *$//;s/^ *//;s/ *$//'
}

# Build a single genre EPUB
build_genre() {
  local genre_slug="$1"

  # Find the metadata file
  local meta_file
  meta_file=$(find "$METADATA_DIR" -name "vol-*-${genre_slug}.yaml" -type f 2>/dev/null | head -1)
  if [[ -z "$meta_file" ]]; then
    log_err "No metadata file found for genre: $genre_slug"
    return 1
  fi

  # Check for compiled markdown
  local input_file="$COMPILED_DIR/${genre_slug}.md"
  if [[ ! -f "$input_file" ]]; then
    log_err "No compiled markdown found: $input_file"
    return 1
  fi

  # Extract metadata
  local volume genre_display subtitle
  volume=$(yaml_field "$meta_file" "volume")
  genre_display=$(yaml_field "$meta_file" "genreDisplay")
  subtitle=$(yaml_field "$meta_file" "subtitle")

  local title="Must Read: ${genre_display}"
  local output_file="$OUTPUT_DIR/${genre_slug}.epub"

  log_info "Building $title (Vol. $volume)..."

  # Ensure output directory exists
  mkdir -p "$OUTPUT_DIR"

  # Construct pandoc arguments
  local -a pandoc_args=(
    "$input_file"
    --to epub3
    --output "$output_file"
    --css "$CSS_FILE"
    --toc
    --toc-depth=1
    --split-level=1
    --metadata "title=${title}"
  )

  # Add subtitle if present
  if [[ -n "$subtitle" ]]; then
    pandoc_args+=(--metadata "subtitle=${subtitle}")
  fi

  # Add cover image if it exists
  local cover_file="$COVERS_DIR/${genre_slug}.jpg"
  if [[ -f "$cover_file" ]]; then
    pandoc_args+=(--epub-cover-image "$cover_file")
    log_info "  Cover image: $cover_file"
  else
    log_info "  No cover image found at $cover_file (building without cover)"
  fi

  # Run pandoc
  if pandoc "${pandoc_args[@]}"; then
    local file_size
    file_size=$(du -h "$output_file" | cut -f1)
    log_ok "$output_file ($file_size)"
  else
    log_err "pandoc failed for $genre_slug"
    return 1
  fi

  # Run epubcheck if available
  if command -v epubcheck &>/dev/null; then
    log_info "  Running epubcheck..."
    if epubcheck "$output_file" 2>&1 | tail -5; then
      log_ok "epubcheck passed for $genre_slug"
    else
      log_err "epubcheck found issues in $genre_slug (see output above)"
      # Don't fail the build for epubcheck warnings — report only
    fi
  elif command -v java &>/dev/null && [[ -f "$PUB_DIR/tools/epubcheck.jar" ]]; then
    log_info "  Running epubcheck (jar)..."
    if java -jar "$PUB_DIR/tools/epubcheck.jar" "$output_file" 2>&1 | tail -5; then
      log_ok "epubcheck passed for $genre_slug"
    else
      log_err "epubcheck found issues in $genre_slug"
    fi
  else
    log_info "  epubcheck not available — skipping validation"
  fi

  return 0
}

# --------------------------------------------------------------------------
# Genre List
# --------------------------------------------------------------------------

ALL_GENRES=(
  adventure
  creative-nonfiction
  crime-noir
  dystopian
  fantasy
  gothic-fiction
  historical-fiction
  horror
  humor-satire
  literary-fiction
  magical-realism
  mystery-thriller
  philosophical-fiction
  romance
  science-fiction
  western
)

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

main() {
  # Check dependencies
  if ! command -v pandoc &>/dev/null; then
    log_err "pandoc is required but not installed. Install with: brew install pandoc"
    exit 1
  fi

  log_info "pandoc version: $(pandoc --version | head -1)"
  log_info "CSS: $CSS_FILE"
  log_info ""

  local genres_to_build=()
  local success_count=0
  local fail_count=0

  if [[ $# -gt 0 ]]; then
    # Build specific genre(s) passed as arguments
    genres_to_build=("$@")
  else
    # Build all genres
    genres_to_build=("${ALL_GENRES[@]}")
  fi

  for genre in "${genres_to_build[@]}"; do
    if build_genre "$genre"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
    echo ""
  done

  # Summary
  log_info "========================================="
  log_info "EPUB build complete"
  log_info "  Success: $success_count"
  log_info "  Failed:  $fail_count"
  log_info "  Output:  $OUTPUT_DIR/"
  log_info "========================================="

  if [[ $fail_count -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
