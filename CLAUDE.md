# Must Read — Claude Code Project Guide

## What This Is

A read-only literary platform: ~13,000 original short works (1,500-10,000 words each) spanning 16 genres and ~130 subgenres, with AI-generated ratings, reviews, and reader personas. Static Astro site deployed to GitHub Pages. All content written by Claude Opus 4.6.

Every work uses a unique 4-element formula: **AuthorA(style) + AuthorB(style) + WorkX(structure) + WorkY(themes)**. The combination is documented per piece and visible to readers.

## Architecture

- **Static site generator**: Astro 5.x with Content Collections (Zod schemas), zero-JS default
- **Hosting**: GitHub Pages from `main` branch, `/docs` folder (org repo, serves at root — NO base path)
- **Content format**: Markdown + YAML frontmatter for works; JSON for reviews and personas
- **Build output**: `docs/` directory (Astro `outDir: './docs'`)
- **Content generation**: Claude Code CLI headless mode with git worktrees for parallelism

## Orchestration Model (MANDATORY)

**You are the manager. Background Opus 4.6 agents are the workers.**

All heavy lifting MUST run in background Task agents, NOT in the main context. This is critical for context window longevity — the main context orchestrates, dispatches, and merges. Workers do the actual coding, generation, and feature work.

### Worker infrastructure:
- **5 git worktrees** at `.worktrees/worker-{1-5}` on branches `worker/slot-{1-5}`
- Each background agent gets a worktree path as its working directory
- Workers commit to their feature branch; main context merges to `main`
- Content paths are unique per work, so merge conflicts are impossible

### Dispatching pattern:
```
1. Main context: plan what needs doing, assign to background agent
2. Background agent: works in its worktree, commits when done
3. Main context: merge feature branch → main, rebuild docs, push
```

### Context preservation across compactions:
- This CLAUDE.md is loaded every turn (survives compaction)
- MEMORY.md in auto-memory dir is also loaded every turn
- When context compacts, re-read this file to restore workflow knowledge
- NEVER do heavy lifting directly — always dispatch to background agents

## Key Files

| File | Purpose |
|------|---------|
| `SPEC.md` | Full technical and creative specification — the source of truth |
| `GENRE_TAXONOMY.md` | Living genre/subgenre/author reference with style descriptions |
| `src/content.config.ts` | Zod schemas for works, reviews, personas |
| `astro.config.mjs` | Site config — output to `docs/`, static mode |
| `manifests/combination-matrix/` | Author/work combos per subgenre (JSON) |
| `manifests/generation-queue.json` | Ordered queue of next pieces to generate |
| `templates/` | Prompt templates: author-meeting, story-planning, work-generation, editor-pass, review-generation, risk-cards, persona-generation |
| `scripts/word-count-distribution.json` | Genre-specific probabilistic word count distributions |
| `personas/` | Reader persona definitions per genre (JSON) |
| `scripts/` | Automation scripts for generation pipeline |

## Content Generation Workflow

**Critical rules:**
1. **Each pipeline stage uses a SEPARATE context.** Planner, writer, editor, and each reviewer are all different agents with fresh eyes. No agent sees another's reasoning or process — only its output.
2. **Reviewers are blind reader proxies.** They know NOTHING about the combination formula, source authors, or how the story was made. They read it cold, like a real reader encountering it on a shelf.

### Target word counts:
Each combination spec includes a `targetWordCount` and `readingTime`, sampled from genre-specific probabilistic distributions defined in `scripts/word-count-distribution.json`. The range is 1,500-10,000 words across all genres, but each genre has its own distribution:
- Horror and humor/satire skew shorter (many 1,500-4,000 word pieces)
- Fantasy, historical fiction, and philosophical fiction skew longer (many 5,000-10,000 word pieces)
- Most genres center around 3,000-6,500 words

**Assignment process:** Roll against the genre's tier weights to select a tier, sample uniformly within that tier's range, then give the writer a window of target ±300 words. At 250 wpm, `readingTimeMinutes = Math.round(targetWordCount / 250)`.

### Risk cards (30% of works):
Each work has a 30% probability of receiving a risk card — a structural constraint that forces the story off the safe path. Risk cards are drawn randomly from the pool in `templates/risk-cards.md`. When assigned, the card is MANDATORY: it shapes the story's architecture, not just decorates it. Cards are not reused within the same generation batch. See the template for the full pool (12 cards: unreliable narrator, non-linear time, story-as-document, ambiguous ending, second person, withheld information, multiple voices, reverse chronology, genre subversion, protagonist is wrong, constraint of space, dual timeline).

### Pipeline per work:
0. **Author Meeting agent** (worker-N): Generates a fabricated meeting/discussion between AuthorA, AuthorB, and the AI writer persona (first-person narrator). The meeting explores the themes, ideas, and creative tensions that will inform the story — but is NOT a planning document or plot outline. It's a creative piece in its own right: real disagreements, concessions, tangents, and moments of agreement that feel like losses. Target length: 2,000-4,000 words. Uses `templates/author-meeting.md`. The meeting output appears on the site: a preview/excerpt on the work's metadata page (with link to full discussion), and a dedicated reading page with full TTS/semantic HTML standards. Commits to feature branch.
1. **Planner agent** (worker-N): Reads the author meeting output + combination spec + genre taxonomy + risk card (if assigned) + existing titles list. Designs the story blueprint: premise, protagonist (with specific flaw), structure (5 beats), key scenes, emotional trajectory, formula integration plan, title. Uses `templates/story-planning.md`. Commits plan to feature branch.
2. **Writer agent** (worker-N, SAME worktree but can be separate context): Reads the story plan + combination spec + genre taxonomy. Executes the plan with exceptional prose. Has creative license to adjust details, but follows the plan's architecture. Uses `templates/work-generation.md`. Commits `.md` file to feature branch.
3. **Editor agent** (worker-M, SEPARATE context): Fresh eyes on the finished piece. Reads the story + combination spec + genre taxonomy + editor template. Uses `templates/editor-pass.md`. Edits for: prose quality, formula adherence, pacing, AI-isms, **structural AI-isms** (tidy epiphanies, every thread resolved, announced themes, symmetrical bookends, balanced perspectives). Makes direct edits — cuts flab, introduces asymmetry, fixes endings. This is a revision, not a review. Commits edits to the same feature branch.
4. **Reviewer agents** (one per persona, in parallel): Each reads ONLY the EDITED work + their persona JSON. NO formula knowledge, NO combination spec, NO knowledge of how the story was made. They are blind reader proxies — genuine reactions from specific fictional readers. Uses `templates/review-generation.md`. Outputs individual review JSON.
5. **Assembler** (manager): Collects individual reviews into the combined reviews JSON file, computes aggregate rating using **weighted average** formula, applies variance expansion if needed, updates the work's frontmatter. See "Weighted Average Rating Formula" below.
6. **Helpful votes agent** (post-processing): Reads the assembled reviews and assigns `helpfulCount` values (0-100) with an organic distribution. Thoughtful, specific, longer reviews receive higher counts. Most cluster in 0-20; a few outliers reach higher.

**Why an author meeting?** The combination formula is a blueprint on paper — four names and their attributes. The fabricated meeting transforms it into creative tension. When AuthorA and AuthorB disagree about how to approach a theme, when the AI narrator proposes something and gets corrected, the ideas that emerge are more surprising and more grounded than what any planning prompt produces cold. The meeting also becomes site content: readers can see the creative process that seeded the story, presented as a literary discussion worth reading on its own.

**Why separate planner and writer?** Invention and execution are different skills. The planner can take risks — an ambitious structure, a protagonist who never changes, an ending that refuses to resolve — because it's not also responsible for sustaining 5,000 words of prose. The writer can focus on craft — sentence rhythm, image, voice — because the architecture is already designed.

**Why a separate editor?** The writer's context has "creator's blindness." A fresh context reading the work cold catches pacing sags, overworked metaphors, weak endings, and **structural AI-isms** (the predictable patterns that emerge from AI-generated fiction at the architectural level, invisible in any single sentence).

**Why blind reviewers?** Previous reviewers knew the formula and rated accordingly — like judges at a wine tasting who can see the label. Blind reviewers react to the text itself, creating organic rating variance. A technically accomplished story that fails to move a reader should get a 3, not a 4-because-the-craft-is-competent.

### Weighted Average Rating Formula

The aggregate rating for each work is a **weighted average** of individual review ratings, where more-helpful reviews carry more weight:

```
rating = Σ(rating_i * sqrt(helpfulCount_i + 1)) / Σ(sqrt(helpfulCount_i + 1))
```

Rounded to 1 decimal place.

**Rationale:** Reviews that readers find more helpful (longer, more specific, more insightful) should carry more weight in the aggregate rating. Using `sqrt` dampens the effect so a single viral review cannot dominate.

**Variance policy:** The target distribution for aggregate ratings across all current works is **2.9 to 4.2**. Ratings of 4.3-5.0 are reserved for genuinely exceptional future work. The floor is 0 and the ceiling is 5.0.

If the weighted average formula alone does not produce sufficient variance (range < 1.3), a **linear expansion** is applied:

```
final_rating = clamp(slope * weighted_avg + intercept, 0, 5.0)
```

where `slope` and `intercept` are calibrated to map the observed weighted average range to [2.9, 4.2]. This is recalibrated whenever new works are added in batch.

### Review file format:
Individual reviews are written to `review-{persona-number}-{name}.json` then assembled into the final `<slug>.json` for the Content Collection.

## Content Rules

1. **Word count**: 1,500-10,000 words per work (6-40 min read). Lengths are sampled from genre-specific probabilistic distributions in `scripts/word-count-distribution.json`. Each work gets a target word count with a ±300 word window. Horror and humor skew shorter; fantasy and historical skew longer. A generation batch should show genuine variety — not all 4,000-word stories.
2. **Banned names**: Never use "Marcus" or "Chen" in generated content
3. **No AI-isms (prose)**: No hedging, lists-as-prose, hollow superlatives, or "delve/tapestry/testament" filler
4. **No AI-isms (structural)**: No too-neat three-act structure, no tidy epiphanies, no every-thread-resolved endings, no announced themes, no symmetrical bookends, no balanced-perspectives-on-all-sides. The editor agent is specifically mandated to catch and fix these. See `templates/editor-pass.md` for the full checklist.
5. **Formula adherence**: Every piece must demonstrably reflect all four sources (authorA, authorB, workX, workY) with identifiable passages
6. **Rating distribution**: Individual review ratings (1-5 integer) come from blind reader proxies and should show natural variance. The aggregate rating per work uses a weighted average formula (weight = sqrt(helpfulCount + 1), rounded to 1 decimal). Across all works, aggregates should distribute from roughly **2.9 to 4.2** for current-quality work. Ratings above 4.2 are reserved for genuinely exceptional pieces. If weighted averages cluster too tightly (range < 1.3), a linear expansion is applied to spread them. Reviews must reference specific text elements. Plenty of 3s, healthy number of 2s, some 5s, occasional 1s. NOT everything is 4 stars.
7. **Review count per work**: 7-12 reviews (natural spread, NOT always 10). Varies per piece.
8. **Review length**: Varies naturally. Most reviews are one paragraph. Some have two paragraphs. A few may be very brief (1-2 sentences) but not every work gets a very short review — don't overdo brevity.
9. **Review dates**: Check system date with `date` command. Reviews dated today or within the past ~7 months. Natural spread across that range — NOT all on the same day.
10. **Review text**: 50-1000 chars per schema. Most reviews 200-600 chars. A few longer, a few shorter. Natural variation.
11. **Blind reviews**: Reviewers are blind reader proxies. They receive ONLY the finished work and their persona profile. NO combination formula, NO source author info, NO knowledge of how the story was constructed. They react as real readers.
12. **Genre splattering**: Generate round-robin across subgenres, never completing one genre while others are empty
13. **Title variety**: Titles MUST NOT fall into repetitive patterns. Specifically: no more than 30% of titles should start with "The". Vary title structures — use single words, phrases, names, questions, imperatives, compound forms, possessives, gerunds, etc. Before choosing a title, check existing titles and deliberately diverge from the dominant pattern.
14. **Risk cards**: ~30% of works receive a risk card (structural constraint). Drawn randomly from the pool in `templates/risk-cards.md`, not reused within the same batch. When assigned, the constraint is MANDATORY and must be architecturally central, not decorative.
15. **Persona name uniqueness**: Persona first names must be unique across the entire platform, not just within a genre. Check existing personas before generating new ones.
16. **Persona consistency**: Each persona's reviews must match their documented preferences, tone, and rating tendency

## Schemas (Quick Reference)

**Work frontmatter** (required fields): title, slug, genre, subgenre, authorA, authorB, workX, workY, wordCount (1500-10000), readingTimeMinutes (6-40), tags, rating, ratingCount, publishedDate, status, formulaSummary, synopsis (max 300 chars), combination (with fromAuthorA, fromAuthorB, fromWorkX, fromWorkY arrays)

**Author Meeting** (Markdown + YAML frontmatter): Fabricated discussion between AuthorA, AuthorB, and the AI writer persona. Stored alongside the work. Frontmatter includes: title, slug, genre, subgenre, authorA, authorB, workSlug (links to the associated work), wordCount, publishedDate. The body is the full meeting dialogue in prose form. Appears on the site as: (a) a preview excerpt on the work's metadata page with link to full discussion, and (b) a dedicated reading page with the same semantic HTML / TTS standards as story pages. Metadata page layout order: story title + metadata, most helpful review + weighted rating, discussion preview + link, all reader reviews.

**Review JSON**: workSlug, reviews[] with personaId, rating (1-5), text (50-1000 chars), date, helpfulCount (0-100, default 0)

**Persona JSON**: id (format: `{genre-abbrev}-{###}-{firstname}`), name (unique across all genres), genre, avatar, bio, readingPreferences (favoriteSubgenres, preferredLength, stylePreference, ratingTendency), reviewStyle (tone, focusAreas, averageLength, vocabularyLevel)

## Git Conventions

- **Branches**: `content/<combo-id>`, `persona/<genre>`, `infra/<feature>`, `fix/<desc>`
- **Commits**: `<type>(<scope>): <description>` with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- **Types**: feat, fix, content, persona, review, infra, docs, style
- **Worktrees**: Up to 5 concurrent for content generation. Each work gets a unique file path so merge conflicts are impossible

## Content File Paths

- Works: `src/content/works/<genre>/<subgenre>/<slug>.md`
- Author Meetings: `src/content/meetings/<genre>/<subgenre>/<slug>-meeting.md`
- Reviews: `src/content/reviews/<genre>/<subgenre>/<slug>.json`
- Personas: `src/content/personas/<genre>/<persona-id>.json` (one file per persona)

## Site Design — Literary Amber

- **Typography**: Lexend throughout (display, reading, UI). Reading column max 65ch
- **Colors**: Warm parchment (#FAF7F2) light / Deep espresso (#1C1410) dark. Accent: dark goldenrod (#B8860B)
- **Dark mode**: `prefers-color-scheme` with manual toggle. Warm tones, not cold blue-black.
- **TTS-first**: Semantic HTML, reviews/metadata outside `<article>` so TTS apps skip them
- **Reading view**: Single column, zero clutter, amber gradient progress bar, drop cap first letter
- **Library view**: Responsive grid (1-4 columns), genre cards with image backgrounds
- **Images**: 21 Gemini-generated images (16 genre + 5 site-wide), processed with ImageMagick, Astro WebP optimization
- **UX rule**: Genre labels on work cards use secondary color (NOT accent) — they are not links

## Development Phases

**Phase 1 (Foundation)**: Astro skeleton, layouts, components, styles, schemas, validation pipeline, GitHub Actions, first 5 golden-example works across 3 genres

**Phase 2 (Pipeline)**: All automation scripts, combination matrices for 16 genres, 1,600 personas, 50-100 works, quality review agent tuning

**Phase 3 (Scale)**: 5 concurrent worktrees, 20-40 works/day, continuous deployment, target 500 works/month

## Open Questions (Resolve Before Building)

See SPEC.md Section 17. Key decisions needed: cover images, reading lists (localStorage), content license, custom domain, analytics, RSS feeds, combination formula visibility, persona profile pages, build-time scaling strategy.

## Quality Validation Checklist (Every PR)

- [ ] Astro build passes (schema validation)
- [ ] Word count within genre-appropriate range (1,500-10,000)
- [ ] No banned names (Marcus, Chen)
- [ ] Rating math: weighted average (sqrt(helpfulCount+1) weights) matches individual reviews, rounded to 1 decimal
- [ ] Rating distribution: aggregates span 2.9-4.2, not clustered; linear expansion applied if range < 1.3
- [ ] Author meeting exists for the work (2,000-4,000 words, genuine intellectual friction)
- [ ] All persona IDs in reviews exist in persona pool
- [ ] No duplicate combo IDs or slugs
- [ ] Style directive honored (identifiable passages per source)
- [ ] Reviews reference specific text from the work
- [ ] Reviews contain NO formula/source references (blind reader proxy check)
- [ ] No structural AI-isms: check endings for tidy resolutions, announced themes
- [ ] Risk card (if assigned) is architecturally central, not decorative
- [ ] Title does not start with "The" (unless under 30% threshold)
- [ ] Persona names are unique across all genres
