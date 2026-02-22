# Must Read — Continuation Prompt for New Machine

Paste this into your first Claude Code session after cloning the repo.

---

## Context

I'm continuing work on the Must Read literary platform. The repo is freshly cloned from GitHub. All state is in the repo and in the CLAUDE.md / MEMORY.md files — no local state to recover.

## Setup required

Before any work, set up the git worktree infrastructure. Create 10 worktrees:

```
for i in $(seq 1 10); do
  git branch -f "worker/slot-$i" main 2>/dev/null
  git worktree add ".worktrees/worker-$i" "worker/slot-$i"
done
```

Verify with `git worktree list` — you should see 10 worktrees plus the main checkout.

## What was just completed

- **Author meeting infrastructure**: meetings content collection added to `src/content.config.ts`, meeting reading page at `src/pages/meeting/[slug].astro`, "Behind the Story" section on work detail pages at `src/pages/work/[slug].astro`
- **32 of 53 works** now have author meetings — fabricated literary discussions between the two source authors and the AI writer persona
- All 32 meetings are live on must-read.org
- All 10 worker branches are synced to main

## Immediate next task: complete author meeting retrofit

**21 works still need author meetings.** These are the slugs:

1. beginning-a-book-you-will-not-finish
2. binding-and-foxing
3. checkout-counter-theory
4. germline-aria
5. iron-and-ink-at-hartwell
6. last-water-before-eden
7. mouth-full-of-rivers
8. ordinary-maintenance-at-the-edge-of-the-knowable
9. palms-and-ashes
10. somnographic-index-of-disappearances
11. the-crying-of-saints
12. the-department-of-nascent-sorrows
13. the-orange-line
14. the-other-side-of-the-lake
15. the-season-of-your-return
16. the-seed-vault-of-oshodi
17. the-stopped-clock-at-ainsworth-street
18. the-woman-who-borrowed
19. unsolicited
20. versions-of-the-parking-lot
21. visiting-fellow

### How to generate each meeting

Dispatch background agents (up to 10 in parallel) using the Task tool. Each agent:

1. Reads the finished story at `src/content/works/<genre>/<subgenre>/<slug>.md` to understand the story's world, characters, voice, and themes
2. Reads `GENRE_TAXONOMY.md` for author style descriptions
3. Reads `templates/author-meeting.md` for the meeting format/instructions
4. Gets the list of existing meeting titles (to avoid duplicating dynamics or titles)
5. Writes the meeting to `src/content/meetings/<genre>/<subgenre>/<slug>-meeting.md`
6. Commits with message: `content(meeting): add author meeting for <Title>`

After each batch completes, merge worker branches to main: `git merge worker/slot-N --no-edit`, then reset the worker: `cd .worktrees/worker-N && git reset --hard main`.

After all 21 are merged: `npx astro build` then push.

### Meeting quality bar

- 2,000-4,000 words
- The writing style of the meeting itself should embody the vibe/genre of the piece
- Real intellectual friction between the authors — disagreements, concessions, tangents
- NOT a planning document — a creative piece in its own right
- The narrator (AI writer persona) is a character, not a moderator
- Frontmatter: title, slug, genre, subgenre, authorA, authorB, workSlug, wordCount, publishedDate (today's date)

## After meetings are complete

Once all 53 works have meetings, the next priorities from the project roadmap are:
- Continue generating new works through the full pipeline (meeting → plan → write → edit → review)
- Round-robin across genres per the genre splattering rule
- Target 20-40 works per day using 10-wide parallelism
