#!/bin/bash
# scripts/generate-work.sh — Generate one work end-to-end
# Usage: ./scripts/generate-work.sh <combination-id>

set -euo pipefail

COMBO_ID="${1:?Usage: generate-work.sh <combination-id>}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BRANCH_NAME="content/${COMBO_ID}"

echo "=== Generating work: ${COMBO_ID} ==="
echo "Repo root: ${REPO_ROOT}"

# 1. Create branch
cd "$REPO_ROOT"
git checkout -b "$BRANCH_NAME" main

# 2. Generate the work
echo "--- Step 1: Writing the piece ---"
claude -p "$(cat <<EOF
Read the combination spec for ${COMBO_ID} from manifests/combination-matrix/.
Read the relevant genre section from GENRE_TAXONOMY.md.
Read the generation template from templates/work-generation.md.
Generate the work following the template instructions exactly.
Save it to the appropriate path under src/content/works/<genre>/<subgenre>/<slug>.md with complete frontmatter.
Then self-review: does the piece honor all four sources in the style_directive?
Revise if needed (max 2 passes).
EOF
)" --model claude-opus-4-6 --allowedTools "Read,Write,Edit,Glob,Grep,Bash"

# 3. Generate reviews
echo "--- Step 2: Generating reviews ---"
claude -p "$(cat <<EOF
Find the work just created under src/content/works/.
Read it completely.
Read the persona pool for this genre from src/content/personas/.
If no persona pool exists, read templates/persona-generation.md and create one first.
Select 8-12 personas with diverse rating tendencies.
Generate reviews following templates/review-generation.md.
Save to the matching path under src/content/reviews/<genre>/<subgenre>/<slug>.json.
Compute the aggregate rating and update the work's frontmatter rating and ratingCount fields.
EOF
)" --model claude-opus-4-6 --allowedTools "Read,Write,Edit,Glob,Grep"

# 4. Commit and push
echo "--- Step 3: Committing and pushing ---"
cd "$REPO_ROOT"
git add src/content/
git commit -m "content(${COMBO_ID}): add new work with reviews

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

git push -u origin "$BRANCH_NAME"

# 5. Create PR
gh pr create \
  --title "Add: ${COMBO_ID}" \
  --body "New work generated from combination ${COMBO_ID}. See files for details." \
  --base main

echo "=== Done: ${COMBO_ID} ==="
