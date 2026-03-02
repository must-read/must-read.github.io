---
description: Verify all framework files and templates are in place
---

# Verify Framework

Confirm all templates, schemas, and config files exist and are current before generating content.

// turbo-all

## 1. Check template files

```bash
ls -la templates/
```

Expected: `author-meeting.md`, `story-planning.md`, `work-generation.md`, `editor-pass.md`, `review-generation.md`, `risk-cards.md`, `persona-generation.md`

## 2. Check schema ranges

```bash
grep -n "wordCount\|readingTimeMinutes" src/content.config.ts
```

Expected: `wordCount` min 1500 max 10000, `readingTimeMinutes` min 6 max 40

## 3. Check word count distribution

```bash
cat scripts/word-count-distribution.json | head -5
```

Should exist and contain genre-specific tier data.

## 4. Verify build passes

```bash
npx astro build
```

Build must succeed with current schema and all existing content.

## 5. Check current inventory

```bash
echo "Works per genre:"
for genre in src/content/works/*/; do echo "  $(basename "$genre"): $(find "$genre" -name '*.md' | wc -l)"; done
echo ""
echo "Total works: $(find src/content/works -name '*.md' | wc -l)"
echo "Total personas: $(find src/content/personas -name '*.json' | wc -l)"
```
