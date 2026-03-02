# Content Generation Pipeline

## Orchestration Model

**You are the manager. Background agents are the workers.**

All heavy lifting MUST run in background agents, NOT in the main context. The main context orchestrates, dispatches, and merges. Workers do the actual coding, generation, and feature work.

### Worker Infrastructure

- **15 git worktrees** at `.worktrees/worker-{1-15}` on branches `worker/slot-{1-15}`
- Each background agent gets a worktree path as its working directory
- Workers commit to their feature branch; main context merges to `main`
- Content paths are unique per work, so merge conflicts are impossible

## Pipeline Stages (Per Work)

Each pipeline stage uses a **SEPARATE** agent context. No agent sees another's reasoning.

### Stage 0 — Author Meeting
Agent generates a fabricated meeting between AuthorA, AuthorB, and the AI writer persona. 2,000–4,000 words. Uses `templates/author-meeting.md`. The meeting output appears on the site as a reading page.

### Stage 1 — Planner
Reads the author meeting + combination spec + genre taxonomy + risk card (if assigned) + existing titles list. Produces story blueprint: premise, protagonist, structure, key scenes, emotional trajectory, title. Uses `templates/story-planning.md`.

### Stage 2 — Writer
Reads the story plan + combination spec + genre taxonomy. Executes the plan with exceptional prose. Uses `templates/work-generation.md`.

### Stage 3 — Editor (FRESH context)
Fresh eyes on the finished piece. Uses `templates/editor-pass.md`. Edits for: prose quality, formula adherence, pacing, AI-isms, **structural AI-isms** (tidy epiphanies, every thread resolved, announced themes, symmetrical bookends). This is a revision, not a review.

### Stage 4 — Blind Reviewers (parallel, isolated)
Each reviewer runs in its own isolated context. Each reads ONLY the edited work + their persona JSON. NO formula knowledge. Uses `templates/review-generation.md`. 7–12 reviewers per work.

### Stage 5 — Assembler (manager)
Collects individual reviews into combined JSON, computes aggregate rating using weighted average, updates work frontmatter, assigns helpful votes.

### Stage 6 — Helpful Votes
Assigns `helpfulCount` values (0–100) with organic distribution. Thoughtful, specific, longer reviews receive higher counts.

## Why This Architecture

- **Separate planner and writer**: Invention and execution are different skills
- **Separate editor**: Creator's blindness — a fresh context catches structural issues
- **Blind reviewers**: Previous reviewers who knew the formula rated accordingly. Blind reviewers react to the text itself
- **Author meeting**: Transforms the formula blueprint into creative tension
