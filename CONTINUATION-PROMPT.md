# Must Read — Continuation Prompt for New Machine

Paste this into your first Claude Code session after cloning the repo.

---

## Context

I'm continuing work on the Must Read literary platform. The repo is freshly cloned from GitHub. All state is in the repo and in the CLAUDE.md / MEMORY.md files — no local state to recover.

## Setup required

Before any work, set up the git worktree infrastructure. Create 15 worktrees:

```
for i in $(seq 1 15); do
  git branch -f "worker/slot-$i" main 2>/dev/null
  git worktree add ".worktrees/worker-$i" "worker/slot-$i"
done
```

Verify with `git worktree list` — you should see 15 worktrees plus the main checkout.

## What was just completed

- **Author meeting infrastructure**: meetings content collection in `src/content.config.ts`, meeting reading page at `src/pages/meeting/[slug].astro`, "Behind the Story" section on work detail pages at `src/pages/work/[slug].astro`
- **All 53 works** now have author meetings (100% coverage) — live on must-read.org
- 178 total pages built and deployed
- All 15 worker branches are synced to main

## Next priorities

The author meeting retrofit is complete. The next phase is scaling content generation through the full pipeline:

### Full pipeline per new work:
0. **Author Meeting** → 1. **Planner** → 2. **Writer** → 3. **Editor** → 4. **Reviewers** (7-12 blind, parallel) → 5. **Assembler** → 6. **Helpful votes**

See CLAUDE.md for full pipeline details, templates, and quality rules.

### Key rules:
- Round-robin across genres (genre splattering rule — never complete one genre while others are empty)
- Each pipeline stage uses a SEPARATE agent context
- Reviewers are blind reader proxies — no formula knowledge
- Target 20-40 works per day using 15-wide parallelism
- Risk cards for ~30% of works (structural constraints)
- Word counts sampled from genre-specific distributions in `scripts/word-count-distribution.json`

### Starting point:
- Check `manifests/generation-queue.json` for the ordered queue of next pieces to generate
- Check `manifests/combination-matrix/` for available combinations per subgenre
- 53 works currently published across 16 genres — aim for balanced expansion
