#!/usr/bin/env bash
# Build print PDFs from compiled genre markdown
# Usage: ./publishing/scripts/build-pdf.sh [genre-slug]
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
OUTPUT_DIR="$PUB_DIR/output/pdf"
TEX_TEMPLATE="$TEMPLATES_DIR/print.tex"

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

log_info() { echo "[pdf] $*"; }
log_ok()   { echo "[pdf] OK: $*"; }
log_err()  { echo "[pdf] ERROR: $*" >&2; }

# Extract a YAML field value from a metadata file (simple grep/sed approach)
yaml_field() {
  local file="$1" field="$2"
  sed -n "s/^${field}: *//p" "$file" | sed 's/^ *"//;s/" *$//;s/^ *//;s/ *$//'
}

# Build a single genre PDF
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
  local output_file="$OUTPUT_DIR/${genre_slug}.pdf"

  log_info "Building $title (Vol. $volume)..."

  # Ensure output directory exists
  mkdir -p "$OUTPUT_DIR"

  # Construct pandoc arguments
  local -a pandoc_args=(
    "$input_file"
    --pdf-engine=xelatex
    --template="$TEX_TEMPLATE"
    --output "$output_file"
    --toc
    --toc-depth=1
    --metadata "title=${title}"
    --metadata "genre=${genre_display}"
  )

  # Add subtitle if present
  if [[ -n "$subtitle" ]]; then
    pandoc_args+=(--metadata "subtitle=${subtitle}")
  fi

  # Add volume number
  if [[ -n "$volume" ]]; then
    pandoc_args+=(--metadata "volume=${volume}")
  fi

  # Run pandoc with XeLaTeX
  log_info "  Running pandoc + XeLaTeX..."
  if pandoc "${pandoc_args[@]}" 2>&1; then
    local file_size
    file_size=$(du -h "$output_file" | cut -f1)
    log_ok "$output_file ($file_size)"
  else
    log_err "pandoc/XeLaTeX failed for $genre_slug"
    return 1
  fi

  # Print page count
  if command -v pdfinfo &>/dev/null; then
    local pages
    pages=$(pdfinfo "$output_file" 2>/dev/null | sed -n 's/^Pages: *//p')
    if [[ -n "$pages" ]]; then
      log_info "  Pages: $pages"
    fi
  elif command -v mdls &>/dev/null; then
    # macOS fallback: use mdls to get page count
    local pages
    pages=$(mdls -name kMDItemNumberOfPages "$output_file" 2>/dev/null | sed -n 's/.*= *//p')
    if [[ -n "$pages" && "$pages" != "(null)" ]]; then
      log_info "  Pages: $pages"
    fi
  else
    log_info "  (pdfinfo not available — page count unknown)"
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

  if ! command -v xelatex &>/dev/null; then
    log_err "XeLaTeX is required but not installed."
    log_err "Install with: brew install --cask mactex  (or: brew install basictex)"
    exit 1
  fi

  log_info "pandoc version: $(pandoc --version | head -1)"
  log_info "xelatex: $(which xelatex)"
  log_info "Template: $TEX_TEMPLATE"
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
  log_info "PDF build complete"
  log_info "  Success: $success_count"
  log_info "  Failed:  $fail_count"
  log_info "  Output:  $OUTPUT_DIR/"
  log_info "========================================="

  if [[ $fail_count -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
