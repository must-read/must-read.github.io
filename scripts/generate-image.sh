#!/bin/bash
# scripts/generate-image.sh — Generate one image via Gemini API
# Usage: ./scripts/generate-image.sh <output-filename> "<prompt>"
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${REPO_ROOT}/.env"

OUTPUT_NAME="${1:?Usage: generate-image.sh <filename> '<prompt>'}"
PROMPT="${2:?Usage: generate-image.sh <filename> '<prompt>'}"
RAW_DIR="${REPO_ROOT}/src/assets/images/raw"
mkdir -p "$RAW_DIR"

curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "import json; print(json.dumps({'contents': [{'parts': [{'text': 'Generate an image: ' + '''${PROMPT}'''}]}], 'generationConfig': {'responseModalities': ['IMAGE', 'TEXT']}}))")" \
  | python3 -c "
import json, sys, base64
data = json.load(sys.stdin)
if 'error' in data:
    print('ERROR:', json.dumps(data['error'], indent=2), file=sys.stderr)
    sys.exit(1)
for part in data.get('candidates', [{}])[0].get('content', {}).get('parts', []):
    if 'inlineData' in part:
        img = base64.b64decode(part['inlineData']['data'])
        outpath = '${RAW_DIR}/${OUTPUT_NAME}'
        ext = part['inlineData']['mimeType'].split('/')[-1]
        if not outpath.endswith(f'.{ext}'):
            outpath = outpath.rsplit('.', 1)[0] + f'.{ext}' if '.' in outpath else outpath + f'.{ext}'
        with open(outpath, 'wb') as f:
            f.write(img)
        print(f'Saved {outpath} ({len(img)} bytes)')
        break
else:
    print('No image in response', file=sys.stderr)
    sys.exit(1)
"
