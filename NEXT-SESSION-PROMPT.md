# Next Session Prompt

Paste this into a new Claude Code session to continue work on the Must Read platform.

---

## Phase 1: Verify Framework Changes

Before generating any new content, verify that all recent framework changes are in place and working. These were implemented in the Feb 2026 session and should already be committed, but confirm:

### Files to check exist and are current:
1. `templates/story-planning.md` — Planner agent template (premise, protagonist, structure, scenes, emotional arc, title)
2. `templates/work-generation.md` — Writer template (references story plan, risk card support, updated word count range)
3. `templates/editor-pass.md` — Editor template (NEW — includes structural AI-ism detection checklist)
4. `templates/review-generation.md` — Review template (REWRITTEN — blind reader proxy model, no formula knowledge)
5. `templates/risk-cards.md` — Pool of 12 structural constraints (30% assignment rate)
6. `templates/persona-generation.md` — Updated with name uniqueness rule and new rating distribution
7. `scripts/word-count-distribution.json` — Genre-specific probabilistic word count tiers
8. `src/content.config.ts` — Schema updated: wordCount min 1500 max 10000, readingTimeMinutes min 6 max 40
9. `CLAUDE.md` — Major update: new pipeline (planner→writer→editor→blind reviewers), risk cards, structural AI-isms, rating targets (3.5/0.8), word count range (1500-10000)

### Quick verification steps:
```
# Check all template files exist
ls templates/

# Check schema has new ranges
grep -n "wordCount\|readingTimeMinutes" src/content.config.ts

# Check distribution file exists
cat scripts/word-count-distribution.json | head -5

# Verify build still passes with new schema
npx astro build
```

If any of these are missing or stale, read CLAUDE.md for the full specification and implement what's missing.

## Phase 2: Generate Next Batch of Stories

Follow the updated pipeline in CLAUDE.md. Here's the orchestration checklist:

### Pre-generation setup:
1. **Check current inventory**: `ls src/content/works/**/` — count works per genre/subgenre. Identify genres with the fewest works for round-robin splattering.
2. **Get existing titles**: Collect all titles to pass to planner agents (title variety rule: ≤30% starting with "The").
3. **Check worktree state**: Ensure all 5 worktrees are clean and on their slot branches.
4. **Select 5 combinations**: Pick genres with fewest works, select subgenres, build combination specs from `GENRE_TAXONOMY.md`. For each:
   - Sample word count from `scripts/word-count-distribution.json` (roll tier, sample within range, ±300 window)
   - Roll for risk card (30% chance). If yes, draw randomly from `templates/risk-cards.md`, no repeats in batch.
   - Build the combination spec with authorA, authorB, workX, workY, fromAuthorA, fromAuthorB, fromWorkX, fromWorkY

### Per-work pipeline (5 works in parallel across worktrees):

**Step 1 — Plan (5 planner agents in parallel):**
- Each agent gets: combination spec, genre taxonomy excerpt, risk card (if any), existing titles, target word count
- Agent reads `templates/story-planning.md` and produces the story blueprint
- Agent commits plan to feature branch (the plan itself doesn't need to be a permanent file — it's passed to the writer)

**Step 2 — Write (5 writer agents in parallel):**
- Each agent gets: the story plan from Step 1, combination spec, genre taxonomy excerpt, risk card (if any)
- Agent reads `templates/work-generation.md` and writes the story
- Agent commits the `.md` file to feature branch

**Step 3 — Edit (5 editor agents in parallel, FRESH contexts):**
- Each agent gets: the finished story, combination spec, risk card (if any)
- Agent reads `templates/editor-pass.md` and makes direct revisions
- **CRITICAL**: Watch for structural AI-isms (tidy epiphanies, all threads resolved, announced themes)
- Agent commits edited story to same feature branch

**Step 4 — Review (7-12 reviewer agents per work, batched):**
- Each agent gets ONLY: the edited story + one persona profile
- **NO combination formula, NO source authors, NO construction details**
- Agent reads `templates/review-generation.md` and writes one review
- Batch into groups of 4-5 agents for parallel execution

**Step 5 — Assemble (manager context):**
- Collect all reviews per work into the reviews JSON
- Compute aggregate rating (should land near mean 3.5, std 0.8 across all works)
- Update work frontmatter with rating, ratingCount
- Assign helpful votes (organic distribution, 0-100)

**Step 6 — Merge and deploy:**
- Merge all feature branches to main
- `npx astro build`
- `git add docs/ && git commit`
- `git pull --rebase origin main -X theirs && git push origin main`

### Quality checks post-generation:
- [ ] No reviews mention combination formula or source authors
- [ ] Rating distribution across batch shows genuine variance (not all 3.8-4.0)
- [ ] Word counts match assigned targets (within ±300 window)
- [ ] Risk card works (if any) are structurally different from non-risk-card works
- [ ] No structural AI-isms survived the editor pass
- [ ] Title variety maintained (≤30% starting with "The")
- [ ] All persona names unique across genres
- [ ] Astro build passes

### Repeat:
Continue generating batches of 5 works, round-robin across genres with fewest works. Each batch follows the full pipeline above. Target: as many works per session as context and rate limits allow.
