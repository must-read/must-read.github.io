#!/usr/bin/env bash
# Generate audiobook from compiled genre markdown using ElevenLabs TTS
# Usage: ./publishing/scripts/generate-audiobook.sh <genre-slug>
#
# Prerequisites:
#   - ELEVENLABS_API_KEY environment variable set
#   - ffmpeg installed
#   - Compiled markdown in publishing/compiled/<genre>.md
#
# Output:
#   publishing/output/audiobook/<genre>.m4b  (Apple Books with chapters)
#   publishing/output/audiobook/<genre>/     (individual MP3 chapters for ACX)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMPILED_DIR="$PROJECT_ROOT/publishing/compiled"
AUDIO_DIR="$PROJECT_ROOT/publishing/output/audiobook"

# ElevenLabs config
VOICE_ID="JBFqnCBsd6RMkjVDRZzb"  # George
MODEL_ID="eleven_turbo_v2_5"
API_URL="https://api.elevenlabs.io/v1/text-to-speech"

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

# Check prerequisites
if [[ -z "${ELEVENLABS_API_KEY:-}" ]]; then
  echo "Error: ELEVENLABS_API_KEY environment variable not set"
  echo "Export it: export ELEVENLABS_API_KEY='your-key-here'"
  exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
  echo "Error: ffmpeg not found"
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <genre-slug>"
  echo ""
  echo "Available genres:"
  for g in "${!GENRE_DISPLAY[@]}"; do
    echo "  $g"
  done | sort
  exit 1
fi

GENRE="$1"
GENRE_NAME="${GENRE_DISPLAY[$GENRE]:-}"

if [[ -z "$GENRE_NAME" ]]; then
  echo "Error: Unknown genre '$GENRE'"
  exit 1
fi

COMPILED="$COMPILED_DIR/${GENRE}.md"
if [[ ! -f "$COMPILED" ]]; then
  echo "Error: Compiled markdown not found at $COMPILED"
  echo "Run compile-content.js first"
  exit 1
fi

GENRE_AUDIO_DIR="$AUDIO_DIR/$GENRE"
mkdir -p "$GENRE_AUDIO_DIR"

echo "=== Must Read — Audiobook Generation ==="
echo "Genre: $GENRE_NAME"
echo ""

# Split compiled markdown into chapters (split on h1 = story titles)
# Each chapter: intro metadata + meeting excerpt + story
# Skip detailed reviews in audio (tedious to listen to)

split_into_chapters() {
  local input="$1"
  local output_dir="$2"
  local chapter_num=0
  local current_file=""

  # Use awk to split on "# " (h1 headings) — each story starts with h1
  awk -v dir="$output_dir" '
    /^# / {
      chapter_num++
      file = sprintf("%s/chapter-%03d.txt", dir, chapter_num)
      # Strip markdown formatting for TTS
      title = substr($0, 3)
      print "Chapter " chapter_num ": " title > file
      print "" >> file
      next
    }
    chapter_num > 0 {
      # Strip markdown formatting for TTS
      gsub(/\*\*/, "", $0)    # bold
      gsub(/\*/, "", $0)      # italic
      gsub(/^#+\s*/, "", $0)  # headings → plain text
      gsub(/^>\s*/, "", $0)   # blockquotes → plain text
      gsub(/^---$/, "", $0)   # horizontal rules → skip
      gsub(/^\|.*\|$/, "", $0) # tables → skip
      if ($0 !~ /^$/ || prev !~ /^$/) {
        file = sprintf("%s/chapter-%03d.txt", dir, chapter_num)
        print >> file
      }
      prev = $0
    }
  ' "$input"

  echo "$chapter_num"
}

echo "Splitting into chapters..."
NUM_CHAPTERS=$(split_into_chapters "$COMPILED" "$GENRE_AUDIO_DIR")
echo "  Found $NUM_CHAPTERS chapters"
echo ""

# Synthesize each chapter
synthesize_chapter() {
  local text_file="$1"
  local mp3_file="$2"
  local chapter_name
  chapter_name=$(head -1 "$text_file")

  echo "  Synthesizing: $chapter_name"

  # Read text, truncate to ElevenLabs limit (5000 chars per request)
  # For longer chapters, we'll need to chunk and concatenate
  local text
  text=$(cat "$text_file")
  local char_count=${#text}

  if [[ $char_count -gt 5000 ]]; then
    # Chunk into 5000-char segments, synthesize each, concatenate
    local chunk_dir
    chunk_dir=$(mktemp -d)
    local chunk_num=0
    local chunk_files=()

    while [[ ${#text} -gt 0 ]]; do
      local chunk="${text:0:5000}"
      # Try to break at a sentence boundary
      local break_pos
      break_pos=$(echo "$chunk" | grep -ob '\.\s' | tail -1 | cut -d: -f1)
      if [[ -n "$break_pos" && "$break_pos" -gt 3000 ]]; then
        chunk="${text:0:$((break_pos + 1))}"
      fi

      ((chunk_num++))
      local chunk_file="$chunk_dir/chunk-$(printf '%03d' $chunk_num).mp3"
      chunk_files+=("$chunk_file")

      curl -s -X POST "$API_URL/$VOICE_ID" \
        -H "xi-api-key: $ELEVENLABS_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$chunk" --arg model "$MODEL_ID" '{
          text: $text,
          model_id: $model,
          voice_settings: {
            stability: 0.5,
            similarity_boost: 0.75,
            style: 0.3
          }
        }')" \
        -o "$chunk_file"

      text="${text:${#chunk}}"

      # Rate limit: 2 requests per second
      sleep 0.5
    done

    # Concatenate chunks
    local concat_list="$chunk_dir/list.txt"
    for f in "${chunk_files[@]}"; do
      echo "file '$f'" >> "$concat_list"
    done
    ffmpeg -f concat -safe 0 -i "$concat_list" -c copy "$mp3_file" -y 2>/dev/null

    rm -rf "$chunk_dir"
    echo "    ($char_count chars, $chunk_num chunks)"
  else
    # Single request
    curl -s -X POST "$API_URL/$VOICE_ID" \
      -H "xi-api-key: $ELEVENLABS_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg text "$text" --arg model "$MODEL_ID" '{
        text: $text,
        model_id: $model,
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.75,
          style: 0.3
        }
      }')" \
      -o "$mp3_file"

    echo "    ($char_count chars)"
  fi
}

echo "Synthesizing audio..."
MP3_FILES=()
for chapter_file in "$GENRE_AUDIO_DIR"/chapter-*.txt; do
  [[ -f "$chapter_file" ]] || continue
  mp3_file="${chapter_file%.txt}.mp3"
  synthesize_chapter "$chapter_file" "$mp3_file"
  MP3_FILES+=("$mp3_file")
done

echo ""
echo "Combining into M4B..."

# Create chapter metadata for M4B
METADATA_FILE="$GENRE_AUDIO_DIR/chapters.txt"
echo ";FFMETADATA1" > "$METADATA_FILE"
echo "title=Must Read: $GENRE_NAME" >> "$METADATA_FILE"
echo "artist=Claude Opus 4.6" >> "$METADATA_FILE"
echo "album=Must Read" >> "$METADATA_FILE"

# Concatenate all MP3s into single MP3, then convert to M4B with chapters
CONCAT_LIST="$GENRE_AUDIO_DIR/concat.txt"
> "$CONCAT_LIST"
for mp3 in "${MP3_FILES[@]}"; do
  echo "file '$(basename "$mp3")'" >> "$CONCAT_LIST"
done

# Concatenate
COMBINED_MP3="$GENRE_AUDIO_DIR/combined.mp3"
ffmpeg -f concat -safe 0 -i "$CONCAT_LIST" -c copy "$COMBINED_MP3" -y 2>/dev/null

# Convert to M4B (AAC in M4A container)
M4B_OUTPUT="$AUDIO_DIR/${GENRE}.m4b"
ffmpeg -i "$COMBINED_MP3" \
  -c:a aac -b:a 64k -ar 22050 -ac 1 \
  -metadata title="Must Read: $GENRE_NAME" \
  -metadata artist="Claude Opus 4.6" \
  -metadata album="Must Read" \
  -metadata genre="Audiobook" \
  "$M4B_OUTPUT" -y 2>/dev/null

if [[ -f "$M4B_OUTPUT" ]]; then
  local size
  size=$(du -h "$M4B_OUTPUT" | cut -f1)
  echo "  OK: $M4B_OUTPUT ($size)"
else
  echo "  FAIL: M4B creation failed"
fi

# Cleanup
rm -f "$COMBINED_MP3" "$CONCAT_LIST"

echo ""
echo "Done. Individual chapter MP3s in: $GENRE_AUDIO_DIR/"
echo "Combined M4B: $M4B_OUTPUT"
