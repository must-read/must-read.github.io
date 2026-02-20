# Must Read — Claude Code Project Guide

## What This Is

A read-only literary platform: ~13,000 original short works (2,500-6,000 words each) spanning 16 genres and ~130 subgenres, with AI-generated ratings, reviews, and reader personas. Static Astro site deployed to GitHub Pages. All content written by Claude Opus 4.6.

Every work uses a unique 4-element formula: **AuthorA(style) + AuthorB(style) + WorkX(structure) + WorkY(themes)**. The combination is documented per piece and visible to readers.

## Architecture

- **Static site generator**: Astro 5.x with Content Collections (Zod schemas), zero-JS default
- **Hosting**: GitHub Pages from `main` branch, `/docs` folder
- **Content format**: Markdown + YAML frontmatter for works; JSON for reviews and personas
- **Build output**: `docs/` directory (Astro `outDir: './docs'`)
- **Content generation**: Claude Code CLI headless mode with git worktrees for parallelism

## Key Files

| File | Purpose |
|------|---------|
| `SPEC.md` | Full technical and creative specification — the source of truth |
| `GENRE_TAXONOMY.md` | Living genre/subgenre/author reference with style descriptions |
| `src/content.config.ts` | Zod schemas for works, reviews, personas |
| `astro.config.mjs` | Site config — output to `docs/`, static mode |
| `manifests/combination-matrix/` | Author/work combos per subgenre (JSON) |
| `manifests/generation-queue.json` | Ordered queue of next pieces to generate |
| `templates/` | Prompt templates for work, review, and persona generation |
| `personas/` | Reader persona definitions per genre (JSON) |
| `scripts/` | Automation scripts for generation pipeline |

## Content Generation Workflow

**Critical rule: Writing and reviewing are separate contexts.** The agent that writes a work must NEVER be the same agent that reviews it. Each reviewer agent gets a fresh context — it reads the finished story and one persona profile, then writes a single review. This ensures genuinely independent perspectives.

### Target word counts:
Each combination spec includes a `targetWordCount` and `readingTime`. These are assigned when building the generation queue, drawn from a natural distribution across the full 2,500-6,000 range:
- ~20% short (2,500-3,200 words, 10-13 min) — tight, focused pieces
- ~40% medium (3,200-4,500 words, 13-18 min) — the sweet spot
- ~30% long (4,500-5,500 words, 18-22 min) — room to breathe
- ~10% extended (5,500-6,000 words, 22-25 min) — epic or complex pieces

The writer agent treats the target as a natural pace, not a hard constraint. A story that wants to be 3,800 words shouldn't be padded to 4,200 or cut to 3,500.

### Pipeline per work:
1. **Writer agent** (single): Reads combination spec (including targetWordCount) + genre taxonomy + template. Writes the piece, self-reviews against the style directive, revises. Outputs the `.md` file.
2. **Reviewer agents** (one per persona, in parallel): Each reads the finished work + their persona JSON. Writes one review. Outputs an individual review JSON.
3. **Assembler** (manager): Collects individual reviews into the combined reviews JSON file, computes aggregate rating, updates the work's frontmatter.
4. **Helpful votes agent** (post-processing): Reads the assembled reviews and assigns `helpfulCount` values (0-100) with an organic distribution. Thoughtful, specific, longer reviews receive higher counts. Most cluster in 0-20; a few outliers reach higher.

### Review file format:
Individual reviews are written to `review-{persona-number}-{name}.json` then assembled into the final `<slug>.json` for the Content Collection.

## Content Rules

1. **Word count**: 2,500-6,000 words per work (10-25 min read). Lengths MUST vary organically — each combination spec includes a target word count. Do NOT produce stories of uniform length. A cozy mystery might be a tight 2,800 words; an epic fantasy excerpt might run 5,500. The generation queue assigns varied targets across the full range.. Each work gets a unique target word count assigned at generation time — vary naturally across the full range. Do NOT make every story the same length. A generation batch should include short punchy pieces (~2,500-3,000), medium (~3,500-4,500), and long (~5,000-6,000). At 250 wpm, the minimum is a true 10-minute read (2,500 words floor).
2. **Banned names**: Never use "Marcus" or "Chen" in generated content
3. **No AI-isms**: No hedging, lists-as-prose, hollow superlatives, or "delve/tapestry/testament" filler
4. **Formula adherence**: Every piece must demonstrably reflect all four sources (authorA, authorB, workX, workY) with identifiable passages
5. **Rating distribution**: Mean ~3.8, std ~0.6 — not uniform praise. Reviews must reference specific text elements
6. **Genre splattering**: Generate round-robin across subgenres, never completing one genre while others are empty
7. **Persona consistency**: Each persona's reviews must match their documented preferences, tone, and rating tendency

## Schemas (Quick Reference)

**Work frontmatter** (required fields): title, slug, genre, subgenre, authorA, authorB, workX, workY, wordCount, readingTimeMinutes, tags, rating, ratingCount, publishedDate, status, formulaSummary, synopsis, combination (with fromAuthorA, fromAuthorB, fromWorkX, fromWorkY arrays)

**Review JSON**: workSlug, reviews[] with personaId, rating (1-5), text (50-1000 chars), date, helpfulCount (0-100, default 0)

**Persona JSON**: id (format: `{genre-abbrev}-{###}-{firstname}`), name, genre, avatar, bio, readingPreferences (favoriteSubgenres, preferredLength, stylePreference, ratingTendency), reviewStyle (tone, focusAreas, averageLength, vocabularyLevel)

## Git Conventions

- **Branches**: `content/<combo-id>`, `persona/<genre>`, `infra/<feature>`, `fix/<desc>`
- **Commits**: `<type>(<scope>): <description>` with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- **Types**: feat, fix, content, persona, review, infra, docs, style
- **Worktrees**: Up to 5 concurrent for content generation. Each work gets a unique file path so merge conflicts are impossible

## Content File Paths

- Works: `src/content/works/<genre>/<subgenre>/<slug>.md`
- Reviews: `src/content/reviews/<genre>/<subgenre>/<slug>.json`
- Personas: `src/content/personas/<genre>/<persona-id>.json` (one file per persona)

## Site Design Essentials

- **Typography**: Lexend for reading, Inter for UI. Reading column max 65ch
- **Dark mode**: `prefers-color-scheme` with manual toggle
- **TTS-first**: Semantic HTML, reviews/metadata outside `<article>` so TTS apps skip them
- **Reading view**: Single column, zero clutter, 3px progress bar at top
- **Library view**: Responsive grid (1-4 columns by breakpoint)

## Development Phases

**Phase 1 (Foundation)**: Astro skeleton, layouts, components, styles, schemas, validation pipeline, GitHub Actions, first 5 golden-example works across 3 genres

**Phase 2 (Pipeline)**: All automation scripts, combination matrices for 16 genres, 1,600 personas, 50-100 works, quality review agent tuning

**Phase 3 (Scale)**: 5 concurrent worktrees, 20-40 works/day, continuous deployment, target 500 works/month

## Open Questions (Resolve Before Building)

See SPEC.md Section 17. Key decisions needed: cover images, reading lists (localStorage), content license, custom domain, analytics, RSS feeds, combination formula visibility, persona profile pages, build-time scaling strategy.

## Quality Validation Checklist (Every PR)

- [ ] Astro build passes (schema validation)
- [ ] Word count 2,500-6,000
- [ ] No banned names (Marcus, Chen)
- [ ] Rating math: aggregate matches individual reviews
- [ ] All persona IDs in reviews exist in persona pool
- [ ] No duplicate combo IDs or slugs
- [ ] Style directive honored (identifiable passages per source)
- [ ] Reviews reference specific text from the work
