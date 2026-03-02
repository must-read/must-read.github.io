---
description: Generate a batch of stories through the full pipeline
---

# Generate Story Batch

Follow these steps to generate a batch of new works through the full pipeline.

## 1. Check Current Inventory

```bash
# Count works per genre
for genre in src/content/works/*/; do echo "$(basename "$genre"): $(find "$genre" -name '*.md' | wc -l)"; done
```

Identify genres with the fewest works for round-robin splattering.

## 2. Collect Existing Titles

```bash
grep -rh "^title:" src/content/works/ | sed 's/title: //' | sort
```

Check that ≤30% start with "The". Deliberately diverge from dominant patterns.

## 3. Select Combinations

- Pick genres with fewest works
- Select subgenres from `manifests/combination-matrix/`
- Build combination specs from `GENRE_TAXONOMY.md`
- Sample word count from `scripts/word-count-distribution.json` (roll tier, sample within range, ±300 window)
- Roll for risk card (30% chance). If yes, draw randomly from `templates/risk-cards.md`, no repeats in batch

## 4. Run the Pipeline (per work)

Each stage uses a SEPARATE agent context:

1. **Author Meeting** — `templates/author-meeting.md`
2. **Planner** — `templates/story-planning.md` (reads meeting output + combo spec + taxonomy + risk card + existing titles)
3. **Writer** — `templates/work-generation.md` (reads plan + combo spec + taxonomy)
4. **Editor** — `templates/editor-pass.md` (FRESH context, watches for structural AI-isms)
5. **Blind Reviewers** — `templates/review-generation.md` (7–12 per work, each isolated, NO formula knowledge)
6. **Assembler** — collect reviews, compute weighted average, update frontmatter, assign helpful votes

## 5. Quality Checks

See `.agents/rules/quality-checklist.md` — run every check before merging.

## 6. Merge, Build, and Deploy

// turbo-all

```bash
git add -A
npx astro build
git add docs/
git commit -m "content(<genre>): add <N> new works"
git pull --rebase origin main
git push origin main
```
