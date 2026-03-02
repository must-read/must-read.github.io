# Must Read — Project Guide

## What This Is

A read-only literary platform: ~13,000 original short works (1,500–10,000 words each) spanning 16 genres and ~130 subgenres, with AI-generated ratings, reviews, and reader personas. Static Astro site deployed to GitHub Pages. All content written by Claude Opus 4.6.

Every work uses a unique 4-element formula: **AuthorA(style) + AuthorB(style) + WorkX(structure) + WorkY(themes)**.

## Architecture

- **Static site generator**: Astro 5.x with Content Collections (Zod schemas), zero-JS default
- **Hosting**: GitHub Pages from `main` branch, `/docs` folder (org repo, serves at root — NO base path)
- **Content format**: Markdown + YAML frontmatter for works; JSON for reviews and personas
- **Build output**: `docs/` directory (Astro `outDir: './docs'`)
- **Content generation**: Claude Code CLI headless mode with git worktrees for parallelism

## Key Files

| File | Purpose |
|------|---------|
| `SPEC.md` | Full technical and creative specification |
| `GENRE_TAXONOMY.md` | Living genre/subgenre/author reference with style descriptions |
| `src/content.config.ts` | Zod schemas for works, reviews, personas |
| `astro.config.mjs` | Site config — output to `docs/`, static mode |
| `manifests/combination-matrix/` | Author/work combos per subgenre (JSON) |
| `manifests/generation-queue.json` | Ordered queue of next pieces to generate |
| `templates/` | Prompt templates: author-meeting, story-planning, work-generation, editor-pass, review-generation, risk-cards, persona-generation |
| `scripts/word-count-distribution.json` | Genre-specific probabilistic word count distributions |

## Content File Paths

- Works: `src/content/works/<genre>/<subgenre>/<slug>.md`
- Author Meetings: `src/content/meetings/<genre>/<subgenre>/<slug>-meeting.md`
- Reviews: `src/content/reviews/<genre>/<subgenre>/<slug>.json`
- Personas: `src/content/personas/<genre>/<persona-id>.json`

## Site Design — Literary Amber

- **Typography**: Lexend throughout. Reading column max 65ch
- **Colors**: Warm parchment (#FAF7F2) light / Deep espresso (#1C1410) dark. Accent: dark goldenrod (#B8860B)
- **Dark mode**: `prefers-color-scheme` with manual toggle. Warm tones, not cold blue-black.
- **TTS-first**: Semantic HTML, reviews/metadata outside `<article>` so TTS apps skip them
- **Reading view**: Single column, zero clutter, amber gradient progress bar, drop cap first letter

## Git Conventions

- **Branches**: `content/<combo-id>`, `persona/<genre>`, `infra/<feature>`, `fix/<desc>`
- **Commits**: `<type>(<scope>): <description>` with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- **Types**: feat, fix, content, persona, review, infra, docs, style
- **Worktrees**: Up to 15 concurrent for content generation

## Development Phase

Currently in **Phase 2** (Pipeline): automation scripts, combination matrices for 16 genres, 1,600 personas, 50–100 works, quality review agent tuning. Target: **Phase 3** (Scale) with 20–40 works/day.

## Also See

Detailed rules, pipeline specification, schemas, and quality checklists are in `.agents/rules/`. Reusable workflows are in `.agents/workflows/`. The original Claude Code guide is in `CLAUDE.md`.
