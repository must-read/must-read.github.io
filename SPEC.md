# Must Read — Technical & Creative Specification

> A read-only literary platform containing ~13,000 original works across every popular genre and subgenre, with AI-generated ratings, reviews, and reader personas. Built as a static Astro site on GitHub Pages. All content produced by Claude Opus 4.6.

---

## Table of Contents

1. [Vision & Core Concept](#1-vision--core-concept)
2. [Technical Architecture](#2-technical-architecture)
3. [Project Structure](#3-project-structure)
4. [Content Data Model](#4-content-data-model)
5. [Genre & Subgenre Taxonomy](#5-genre--subgenre-taxonomy)
6. [The Combination Engine](#6-the-combination-engine)
7. [Reader Personas](#7-reader-personas)
8. [Content Generation Pipeline](#8-content-generation-pipeline)
9. [Quality Control](#9-quality-control)
10. [Site Design & Reading Experience](#10-site-design--reading-experience)
11. [Search, Filter & Navigation](#11-search-filter--navigation)
12. [TTS Optimization](#12-tts-optimization)
13. [Git Workflow & Automation](#13-git-workflow--automation)
14. [GitHub Actions & Deployment](#14-github-actions--deployment)
15. [Claude Code CLI Workflow](#15-claude-code-cli-workflow)
16. [Scaling Strategy](#16-scaling-strategy)
17. [Open Questions](#17-open-questions)

---

## 1. Vision & Core Concept

Must Read is what Goodreads would be if it contained the books themselves — a curated, browsable, searchable library of original short-form literature you can read right there in the browser or pipe to Speechify / ElevenReader. Every piece is a 10-25 minute read (2,500-6,000 words). The library spans every major genre and subgenre of popular fiction and creative nonfiction.

### What Makes It Different

- **The writing is the product.** Not metadata about writing. Not reviews of writing you have to buy elsewhere. The actual text, on the page, free to read.
- **Massive, systematic coverage.** ~130 subgenres, 100 works each. Not a handful of curated stories — an entire literary landscape generated through disciplined combinatorial creativity.
- **Every piece has a unique formula.** Each work combines the styles of two authors and the structural/thematic DNA of two canonical works from its genre. The formula is documented and visible. Readers can explore "What does Ursula K. Le Guin's voice sound like inside a William Gibson plot structure?"
- **A living social layer — all simulated.** 100 reader personas per genre, each with distinct preferences and review styles. The reviews are themselves a form of literary criticism, written in character. The ratings form a distribution that reflects genuine taste variation, not uniform praise.
- **Optimized for reading.** Not a content farm. Not a demo. A production reading experience: Lexend typography, fluid sizing, dark mode, TTS-first semantic HTML, zero clutter.

### Intended Audience

- Readers who consume short fiction and want a vast, browsable library
- People who use TTS apps (Speechify, ElevenReader) for commute/exercise listening
- Readers curious about genre conventions and author styles — the combination formula is an educational feature
- Anyone who wants to discover new genres through actual reading, not just descriptions

### Scale

| Dimension | Count |
|-----------|-------|
| Major genres | ~16 |
| Subgenres | ~130 |
| Works per subgenre | 100 |
| Total works | ~13,000 |
| Reader personas per genre | ~100 |
| Total unique personas | ~1,600 |
| Reviews per work | 5-15 |
| Total reviews | ~130,000 |
| Words of fiction | ~52-78 million |

---

## 2. Technical Architecture

### Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Static site generator | **Astro 5.x** | Content Collections with Zod schemas, zero-JS default, TypeScript-native, first-class GitHub Pages support |
| Language | **TypeScript** | Type safety for schemas, build scripts, and content validation |
| Hosting | **GitHub Pages** | Free, reliable, custom domain support, integrated with Actions |
| CI/CD | **GitHub Actions** | Automated builds, content validation, deployment via `withastro/action@v5` |
| Content format | **Markdown + YAML frontmatter** | Works natively with Astro Content Collections |
| Metadata indexes | **JSON** | Build-time search indexes, persona databases, combination manifests |
| Content generation | **Claude Code CLI (headless)** | `claude -p` for batch generation, `claude -w` for parallel worktrees |
| AI model | **Claude Opus 4.6** | Highest quality for literary generation and nuanced review writing |
| Version control | **Git** with feature branches, worktrees, PRs | Full audit trail for every piece of content |

### Astro Configuration

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://must-read.github.io',
  output: 'static',
  outDir: './docs',
  build: {
    format: 'directory',
  },
  markdown: {
    shikiConfig: { theme: 'css-variables' },
  },
});
```

### Content Collections Schema

```typescript
// src/content.config.ts
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const works = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/works' }),
  schema: z.object({
    title: z.string(),
    slug: z.string(),
    genre: z.string(),
    subgenre: z.string(),
    authorA: z.string(),
    authorB: z.string(),
    workX: z.string(),
    workY: z.string(),
    wordCount: z.number().min(2500).max(6000),
    readingTimeMinutes: z.number().min(10).max(25),
    tags: z.array(z.string()),
    rating: z.number().min(1).max(5),
    ratingCount: z.number(),
    publishedDate: z.coerce.date(),
    status: z.enum(['draft', 'review', 'published']),
    formulaSummary: z.string(),
    synopsis: z.string().max(300),
  }),
});

const reviews = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/reviews' }),
  schema: z.object({
    workSlug: z.string(),
    reviews: z.array(z.object({
      personaId: z.string(),
      rating: z.number().min(1).max(5),
      text: z.string().min(50).max(1000),
      date: z.coerce.date(),
    })),
  }),
});

const personas = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/personas' }),
  schema: z.object({
    id: z.string(),
    name: z.string(),
    genre: z.string(),
    avatar: z.string(),
    bio: z.string().max(300),
    readingPreferences: z.object({
      favoriteSubgenres: z.array(z.string()),
      preferredLength: z.enum(['short', 'medium', 'long']),
      stylePreference: z.enum(['literary', 'accessible', 'experimental', 'traditional']),
      ratingTendency: z.enum(['generous', 'moderate', 'critical', 'harsh']),
    }),
    reviewStyle: z.object({
      tone: z.string(),
      focusAreas: z.array(z.string()),
      averageLength: z.number(),
      vocabularyLevel: z.enum(['casual', 'educated', 'academic', 'mixed']),
    }),
  }),
});

export const collections = { works, reviews, personas };
```

---

## 3. Project Structure

```
must-read.github.io/                 # Single repo — site + orchestration
  CLAUDE.md                          # Persistent AI advisor context
  SPEC.md                           # This file
  GENRE_TAXONOMY.md                 # Living genre/subgenre/author reference

  manifests/                        # Generation manifests (what to build)
    combination-matrix/             # Author/work combinations per subgenre
      literary-fiction.json
      science-fiction.json
      ...
    generation-queue.json           # Ordered queue of next pieces to generate
    completed.json                  # Registry of completed works

  personas/                         # Reader persona definitions
    literary-fiction/
      personas.json                 # 100 personas for this genre
    science-fiction/
      personas.json
    ...

  scripts/                          # Automation scripts
    generate-work.sh                # End-to-end: write + review + rate one piece
    generate-combination-matrix.sh  # Build author/work combos for a subgenre
    generate-personas.sh            # Create reader personas for a genre
    generate-reviews.sh             # Generate reviews for a published work
    validate-content.sh             # Schema + quality validation
    queue-next-batch.sh             # Select next N works across genres
    publish-work.sh                 # PR + merge + deploy workflow

  templates/                        # Prompt templates for Claude
    work-generation.md              # Master prompt for writing a piece
    review-generation.md            # Master prompt for generating reviews
    persona-generation.md           # Master prompt for creating personas
    quality-review.md               # Master prompt for quality review pass

  .claude/
    skills/
      generate-work/SKILL.md
      review-work/SKILL.md
      create-personas/SKILL.md
    agents/
      content-reviewer.md
      style-consistency-checker.md
      genre-accuracy-reviewer.md
    settings.json

  .github/
    workflows/
      deploy.yml                    # Build + deploy to GitHub Pages
      validate-content.yml          # PR check: schema + quality validation
      claude-review.yml             # Claude Code Action for PR review
    ISSUE_TEMPLATE/
      new-work.md
      bug-report.md
    PULL_REQUEST_TEMPLATE.md

  docs/                              # GitHub Pages serves from here
  src/
    content/
      works/                        # 13,000 markdown files
        literary-fiction/
          bildungsroman/
            the-glass-apprentice.md
            ...
          autofiction/
            ...
        science-fiction/
          hard-sf/
            ...
          cyberpunk/
            ...
      reviews/                      # One JSON file per work
        literary-fiction/
          bildungsroman/
            the-glass-apprentice.json
        ...
      personas/                     # One JSON file per genre
        literary-fiction.json
        science-fiction.json
        ...
    layouts/
      BaseLayout.astro
      ReadingLayout.astro
      LibraryLayout.astro
      PersonaLayout.astro
    pages/
      index.astro                   # Homepage: featured, recent, genre grid
      browse/
        index.astro                 # Full library with filters
        [genre]/
          index.astro               # Genre landing page
          [subgenre]/
            index.astro             # Subgenre listing
      work/
        [slug].astro                # Individual reading page
      persona/
        [id].astro                  # Persona profile page
      about.astro
      search.astro
    components/
      WorkCard.astro
      StarRating.astro
      ReviewCard.astro
      PersonaBadge.astro
      GenreNav.astro
      FilterBar.astro
      SearchBox.astro
      ReadingProgress.astro
      ThemeToggle.astro
      TOC.astro
    styles/
      global.css
      reading.css
      library.css
      variables.css
    scripts/
      search-index.ts               # Build-time: generates search JSON
      filter.ts                     # Client-side genre/tag filtering
      reading-progress.ts           # localStorage reading tracker
      theme.ts                      # Light/dark mode toggle
  astro.config.mjs
  tsconfig.json
  package.json
```

### Single-Repo Architecture

Everything lives in one repo: `https://github.com/must-read/must-read.github.io`. The `docs/` folder is the GitHub Pages deploy target (served from the `main` branch). Specs, manifests, scripts, and tooling live at the repo root alongside the Astro source. The Astro build outputs to `docs/`. This keeps all cross-references simple and avoids cross-repo scripting.

---

## 4. Content Data Model

### Work Frontmatter (Complete Example)

```yaml
---
title: "The Glass Apprentice"
slug: "the-glass-apprentice"
genre: "literary-fiction"
subgenre: "bildungsroman"
authorA: "Kazuo Ishiguro"
authorB: "Chimamanda Ngozi Adichie"
workX: "Never Let Me Go"
workY: "Purple Hibiscus"
wordCount: 4200
readingTimeMinutes: 17
tags:
  - coming-of-age
  - memory
  - cultural-identity
  - restraint
  - family
rating: 4.3
ratingCount: 12
publishedDate: 2026-03-15
status: published
formulaSummary: >
  Ishiguro's restrained, memory-haunted narration meets Adichie's luminous
  cultural specificity. Structured like Never Let Me Go's slow revelation of
  what's been lost, but grounded in Purple Hibiscus's domestic awakening
  within a rigid household.
synopsis: >
  A young glassblower in Lagos recalls her apprenticeship under a master
  whose exacting standards masked a secret about her own origins — a truth
  she can only see clearly now, years later, through the distortion of memory.
combination:
  fromAuthorA:
    - Understated first-person narration with unreliable memory
    - Emotional restraint — devastation delivered in quiet, almost casual sentences
    - Recurring motifs (glass, light, refraction) that accumulate symbolic weight
  fromAuthorB:
    - Precise sensory details rooted in a specific Nigerian cultural context
    - Warmth and intimacy in family scenes, even when depicting constraint
    - Code-switching between formal English and Igbo-inflected domestic speech
  fromWorkX:
    - Retrospective structure — narrator looking back, revealing information the reader
      doesn't yet know is significant
    - The slow, devastating realization that shapes the entire narrative in hindsight
  fromWorkY:
    - A young protagonist awakening to the world beyond a controlling household
    - The domestic space as both prison and sanctuary
    - A pivotal act of quiet defiance that reshapes the family dynamic
---

The workshop smelled of silica and kerosene, and if I close my eyes now I can
still feel the heat on my forearms...
```

### Review Data (Complete Example)

```json
{
  "workSlug": "the-glass-apprentice",
  "reviews": [
    {
      "personaId": "lit-fic-047-adaeze",
      "rating": 5,
      "text": "This is the kind of story that sneaks up on you. I thought I was reading about glassblowing and then realized, three pages in, that every detail about light passing through glass was really about how memory distorts what we think we saw clearly. The Igbo grandmother felt so real I could hear her. Devastating final paragraph.",
      "date": "2026-03-18"
    },
    {
      "personaId": "lit-fic-012-gerald",
      "rating": 3,
      "text": "Beautifully written but I found the pacing too slow for my taste. The revelation at the end, while emotionally effective, felt telegraphed by the third page. I prefer my literary fiction with more narrative momentum. The prose itself is impeccable, though — some sentences I read twice just for the pleasure of them.",
      "date": "2026-03-20"
    }
  ]
}
```

### Persona Data (Complete Example)

```json
{
  "id": "lit-fic-047-adaeze",
  "name": "Adaeze Okonkwo",
  "genre": "literary-fiction",
  "avatar": "lit-fic-047",
  "bio": "Doctoral student in comparative literature at Ibadan. Reads voraciously across African and diaspora fiction. Impatient with novels that treat Africa as backdrop rather than subject. Believes the best literary fiction makes you feel homesick for a place you've never been.",
  "readingPreferences": {
    "favoriteSubgenres": ["bildungsroman", "autofiction", "domestic-drama"],
    "preferredLength": "medium",
    "stylePreference": "literary",
    "ratingTendency": "generous"
  },
  "reviewStyle": {
    "tone": "warm, analytical, occasionally rhapsodic",
    "focusAreas": ["cultural authenticity", "emotional resonance", "prose craft", "representation"],
    "averageLength": 120,
    "vocabularyLevel": "educated"
  }
}
```

---

## 5. Genre & Subgenre Taxonomy

The living reference is `GENRE_TAXONOMY.md` in this repo. It contains:

- 16 major genres with defining characteristics
- ~130 subgenres with descriptions
- 10-13 authors per genre with style descriptions optimized for combinatorial use
- Cross-genre combination notes
- Genre bridge authors who work across categories

### Taxonomy Maintenance Rules

1. `GENRE_TAXONOMY.md` is the single source of truth for genre definitions, subgenre lists, and author style descriptions.
2. When adding a new subgenre, you must also add at least 10 authors whose styles are distinctive enough for combination.
3. Author style descriptions must focus on **sentence-level patterns**, **narrative structures**, **thematic preoccupations**, and **tonal registers** — not biographical facts.
4. Each genre section must include enough authors to produce at least 100 unique two-author combinations: C(n,2) >= 100, so n >= 15. If a genre has fewer than 15 authors, add more before generating content for it.
5. Cross-genre authors (e.g., Atwood, Le Guin, Morrison) appear in multiple genre sections with style descriptions specific to their work in that genre.

---

## 6. The Combination Engine

Every work is defined by a unique 4-element combination:

```
Work = AuthorA(style) + AuthorB(style) + WorkX(structure/themes) + WorkY(structure/themes)
```

### Combination Matrix Generation

For each subgenre, generate a combination matrix:

```json
{
  "subgenre": "cyberpunk",
  "genre": "science-fiction",
  "combinations": [
    {
      "id": "sf-cyber-001",
      "authorA": "William Gibson",
      "authorB": "Octavia Butler",
      "workX": "Neuromancer",
      "workY": "Parable of the Sower",
      "premise_seed": "A neural-jacked street hustler in a corporate-controlled Lagos discovers that the AI she's been hired to crack is dreaming of building a community beyond the city walls.",
      "style_directive": {
        "fromAuthorA": [
          "Gibson's jagged, neon-lit imagery and brand-name-as-texture prose",
          "Short, punchy sentences alternating with dense sensory overload",
          "Technology described through its wear and street-level repurposing, not specs"
        ],
        "fromAuthorB": [
          "Butler's unflinching focus on survival, community, and adaptation",
          "Grounded emotional realism even in speculative settings",
          "Protagonists who lead through empathy and practical intelligence, not violence"
        ],
        "fromWorkX": [
          "The heist/infiltration plot structure with escalating digital danger",
          "The sense that cyberspace is a real place with its own geography and weather",
          "Corporate power as the true antagonist, not any individual villain"
        ],
        "fromWorkY": [
          "The journey-as-escape structure — leaving a failing city for uncertain hope",
          "Community-building as radical act in a collapsing society",
          "A protagonist who writes her own belief system as she goes"
        ]
      },
      "status": "pending"
    }
  ]
}
```

### Combination Rules

1. **No duplicate pairs.** AuthorA+AuthorB is the same as AuthorB+AuthorA. Each pair appears at most once per subgenre.
2. **Style contrast is preferred.** A minimalist + maximalist pairing (Hemingway + Rushdie) produces more distinctive results than two similar stylists.
3. **Works must be from the genre.** WorkX and WorkY must be recognized works in the target genre or subgenre. Cross-genre works are allowed only if they're commonly shelved in the target genre.
4. **The premise_seed is a starting point, not a constraint.** The actual piece may diverge significantly during generation — the seed just ensures the combination has narrative potential.
5. **Each combination must specify exactly what is borrowed from each source.** The `style_directive` is not optional. Vague directives like "combine their styles" are rejected.

### How Many Combinations Per Subgenre

For 100 works per subgenre, you need 100 unique 4-element combinations. With 15 authors:
- Author pairs: C(15,2) = 105 (sufficient)
- Work pairs: Need at least ~15 works to get C(15,2) = 105 pairs
- Total unique combos: 105 x 105 = 11,025 (far more than 100 needed)

Select 100 combinations that maximize style contrast and thematic interest.

---

## 7. Reader Personas

### Persona Design Principles

Each genre has ~100 reader personas. These are not generic reviewers — they are distinctive fictional readers with consistent tastes, blind spots, and writing styles.

**Diversity requirements per genre's persona pool:**
- Age range: 18-75
- Geographic diversity: at minimum North America, Europe, Africa, Asia, Latin America, Oceania
- Gender diversity: roughly balanced, including non-binary personas
- Reading sophistication: from casual genre fans to academic specialists
- Rating tendencies: distribution from generous to harsh (mean ~3.8, std ~0.6)

**Persona ID format:** `{genre-abbrev}-{number:03d}-{firstname-lowercase}`
Example: `lit-fic-047-adaeze`, `sf-012-hiroshi`, `horror-089-valentina`

### What Makes a Good Persona

A persona is good if you can predict, from their profile alone, whether they'd enjoy a specific work and what they'd say about it. The profile must encode enough about their taste that their reviews are internally consistent.

Bad persona: "Enjoys science fiction. Likes well-written books." (Too generic. Could be anyone.)

Good persona: "Retired aerospace engineer. Reads hard SF exclusively. Has no patience for faster-than-light travel or telepathy — if you can't show the math, don't bother. Writes terse, technical reviews that focus on plausibility. Gives 5 stars rarely and only for books that respect physics. Thinks Ted Chiang is the only living SF writer who matters."

### Review Generation Protocol

For each published work:
1. Select 5-15 personas from the work's genre pool
2. Selection must include at least one generous rater, one critical rater, and one moderate rater
3. Each persona reads the work and generates a review consistent with their profile
4. Reviews must reference specific elements of the text — not generic praise/criticism
5. The aggregate rating must fall in a plausible distribution (not all 4s and 5s)
6. At least one review should engage with the combination formula itself ("You can really feel the Ishiguro influence in how the narrator circles around the truth without ever stating it directly")

---

## 8. Content Generation Pipeline

### The Lifecycle of a Single Work

```
1. MANIFEST    → Combination selected from matrix, added to generation queue
2. GENERATE    → Claude writes the piece using the combination's style directive
3. SELF-REVIEW → Same session: Claude reviews its own work against the directive
4. REVISE      → Claude revises based on self-review (1-2 passes max)
5. VALIDATE    → Schema validation, word count check, banned-name check
6. REVIEW      → Separate Claude session reviews for quality (genre accuracy, prose quality, formula adherence)
7. RATINGS     → 5-15 personas generate reviews and ratings
8. PR          → Work + reviews committed, PR opened against site repo
9. MERGE       → PR merged (auto-merge if validation passes, manual review for flagged issues)
10. PUBLISH    → GitHub Actions builds and deploys
```

### Generation Prompt Structure

The master prompt for generating a work (stored in `templates/work-generation.md`) must include:

1. The complete combination spec (authorA, authorB, workX, workY, style_directive)
2. Target word count range
3. Genre and subgenre conventions (pulled from GENRE_TAXONOMY.md)
4. Hard constraints (banned names, content guidelines)
5. A concrete example of a completed work in the same subgenre (the "golden example")
6. Instructions to self-review against the style_directive before finalizing

### Genre Splattering

Works are not generated sequentially within a genre. The generation queue is built by round-robin sampling across all subgenres:

```
Batch 1: 1 literary-fiction/bildungsroman, 1 sf/cyberpunk, 1 fantasy/epic, 1 mystery/cozy, ...
Batch 2: 1 literary-fiction/autofiction, 1 sf/hard-sf, 1 fantasy/urban, 1 mystery/noir, ...
```

This ensures:
- No genre is "complete" while others are empty — the site always has breadth
- Each generation session encounters different genre conventions, reducing drift
- The site can be published and useful long before all 13,000 works exist

### Batch Script (Conceptual)

```bash
#!/bin/bash
# scripts/generate-work.sh — Generate one work end-to-end
# Usage: ./scripts/generate-work.sh <combination-id>

COMBO_ID=$1
WORKTREE_NAME="work-${COMBO_ID}"

# 1. Create isolated worktree
claude -w "$WORKTREE_NAME" -p "$(cat <<EOF
Read the combination spec for ${COMBO_ID} from manifests/combination-matrix/.
Read the relevant genre section from GENRE_TAXONOMY.md.
Read the generation template from templates/work-generation.md.
Generate the work following the template instructions exactly.
Save it to src/content/works/<genre>/<subgenre>/<slug>.md with complete frontmatter.
Then self-review: does the piece honor all four sources in the style_directive?
Revise if needed (max 2 passes).
Validate the frontmatter against the schema in src/content.config.ts.
EOF
)" --allowedTools "Read,Write,Edit,Bash(npm run validate *)" \
   --model claude-opus-4-6

# 2. Generate reviews in the same worktree
claude -w "$WORKTREE_NAME" -p "$(cat <<EOF
Read the work at src/content/works/<genre>/<subgenre>/<slug>.md.
Read the persona pool for this genre from personas/<genre>/personas.json.
Select 8-12 personas with diverse rating tendencies.
Generate reviews following templates/review-generation.md.
Save to src/content/reviews/<genre>/<subgenre>/<slug>.json.
Compute the aggregate rating and update the work's frontmatter.
EOF
)" --allowedTools "Read,Write,Edit" \
   --model claude-opus-4-6

# 3. Commit, push, PR
cd ".claude/worktrees/${WORKTREE_NAME}"
git add -A
git commit -m "feat(content): add ${COMBO_ID} — <title> [<genre>/<subgenre>]

Combination: <authorA> × <authorB> | <workX> × <workY>
Word count: <N>
Reviews: <N> from <N> personas
Rating: <N>/5 (<N> ratings)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

git push -u origin "content/${COMBO_ID}"
gh pr create \
  --title "Add: <title> [<genre>/<subgenre>]" \
  --body "$(cat <<'PREOF'
## Content
- **Genre**: <genre> / <subgenre>
- **Combination**: <authorA> × <authorB> | <workX> × <workY>
- **Word count**: <N>
- **Reading time**: ~<N> min

## Reviews
- <N> reviews from <N> personas
- Rating: <N>/5

## Checklist
- [ ] Schema validation passes
- [ ] Word count in range (2,500-6,000)
- [ ] No banned names
- [ ] Style directive honored
- [ ] Reviews reference specific text elements
PREOF
)"
```

---

## 9. Quality Control

### Automated Validation (CI)

Every PR triggers:

1. **Schema validation**: All frontmatter fields present and correctly typed (Astro build catches this)
2. **Word count check**: Body text between 2,500 and 6,000 words
3. **Banned name check**: Grep for "Marcus" and "Chen" in all new/modified content files
4. **Rating consistency**: Aggregate rating matches individual review ratings
5. **Link integrity**: All persona IDs in reviews exist in the persona pool
6. **Uniqueness check**: No duplicate combination IDs, no duplicate slugs

### AI Quality Review (Separate Context)

A dedicated Claude agent reviews each piece for:

1. **Formula adherence**: Does the piece actually reflect the four sources? Can you identify specific passages that embody each source's contribution?
2. **Genre accuracy**: Would a reader of this subgenre recognize it as belonging there?
3. **Prose quality**: Is the writing at a professional level? No AI-isms (hedging, lists-as-prose, hollow superlatives)?
4. **Narrative completeness**: Does the piece work as a standalone story/essay with a beginning, middle, and end?
5. **Review authenticity**: Do the reviews sound like they were written by different people? Do they engage with the actual text?

### Quality Flags

Works are flagged for human review if:
- Quality review scores below threshold on any dimension
- Rating distribution is suspiciously uniform
- Multiple reviews use similar phrasing (persona bleed)
- Word count is at the extremes (<2,800 or >5,800)

---

## 10. Site Design & Reading Experience

### Typography

```css
/* variables.css */
:root {
  /* Fonts */
  --font-reading: 'Lexend', system-ui, -apple-system, sans-serif;
  --font-ui: 'Inter', system-ui, -apple-system, sans-serif;

  /* Reading typography */
  --font-size-reading: clamp(1.125rem, 1rem + 0.5vw, 1.375rem); /* 18px-22px */
  --line-height-reading: 1.55;
  --letter-spacing-reading: 0.01em;
  --max-width-reading: 65ch;
  --paragraph-spacing: 1.5em;

  /* Heading scale */
  --font-size-h1: clamp(1.75rem, 1.5rem + 1vw, 2.5rem);
  --font-size-h2: clamp(1.375rem, 1.25rem + 0.5vw, 1.75rem);
  --font-size-h3: clamp(1.125rem, 1rem + 0.375vw, 1.375rem);

  /* Light mode (default) */
  --color-bg: #FAFAF8;
  --color-text: #1A1A1A;
  --color-text-secondary: #555555;
  --color-accent: #2563EB;
  --color-border: #E5E5E5;
  --color-surface: #FFFFFF;
  --color-star: #F59E0B;

  /* Reading-specific */
  --reading-font-weight: 400;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #1A1A2E;
    --color-text: #E0E0E0;
    --color-text-secondary: #A0A0A0;
    --color-accent: #60A5FA;
    --color-border: #2D2D3F;
    --color-surface: #232338;
    --color-star: #FBBF24;

    --reading-font-weight: 420;
    --letter-spacing-reading: 0.015em;
  }
}
```

```css
/* reading.css */
.reading-content {
  max-width: var(--max-width-reading);
  margin: 0 auto;
  padding: 2rem 1.5rem 6rem;
  font-family: var(--font-reading);
  font-size: var(--font-size-reading);
  font-weight: var(--reading-font-weight);
  line-height: var(--line-height-reading);
  letter-spacing: var(--letter-spacing-reading);
  color: var(--color-text);
}

.reading-content p {
  margin-bottom: var(--paragraph-spacing);
}

.reading-content blockquote {
  border-left: 3px solid var(--color-accent);
  padding-left: 1.25em;
  margin: 2em 0;
  color: var(--color-text-secondary);
  font-style: italic;
}

.reading-content hr {
  border: none;
  text-align: center;
  margin: 2.5em 0;
}

.reading-content hr::after {
  content: '* * *';
  color: var(--color-text-secondary);
  letter-spacing: 0.5em;
}
```

### Layout Principles

- **Reading view**: Single column, max 65ch, generous vertical whitespace. Nothing competes with the text. Controls (theme toggle, progress, back nav) are minimal and peripheral.
- **Library view**: Responsive grid — 1 column mobile, 2 tablet, 3-4 desktop. Cards show title, genre, rating, reading time, first line of synopsis.
- **No sidebar on reading pages.** Reviews and metadata appear below the text, after you've finished reading.
- **Progress bar**: Thin (3px), fixed to top of viewport, shows scroll position. Unobtrusive.

### Responsive Breakpoints

```css
/* Mobile-first */
.library-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
  padding: 1rem;
}

@media (min-width: 768px) {
  .library-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 1024px) {
  .library-grid { grid-template-columns: repeat(3, 1fr); gap: 1.5rem; }
}

@media (min-width: 1440px) {
  .library-grid { grid-template-columns: repeat(4, 1fr); }
}
```

---

## 11. Search, Filter & Navigation

### Build-Time Search Index

At build time, generate a JSON search index containing every work's searchable metadata:

```typescript
// scripts/search-index.ts
interface SearchEntry {
  title: string;
  slug: string;
  genre: string;
  subgenre: string;
  authorA: string;
  authorB: string;
  tags: string[];
  rating: number;
  readingTimeMinutes: number;
  synopsis: string;
}
```

Use **Fuse.js** for client-side fuzzy search (title, author names, tags, synopsis). Index size for 13,000 entries: ~5-8MB JSON. Lazy-load on first search interaction.

### Filter Architecture

| Filter | Type | UI |
|--------|------|-----|
| Genre | Single-select | Horizontal pill bar (top-level nav) |
| Subgenre | Multi-select | Collapsible checkbox list under genre |
| Tags | Multi-select | Autocomplete input with pill display |
| Rating | Threshold | "4+ stars" dropdown or star selector |
| Reading time | Range | Predefined buckets: "Quick (10-15 min)", "Medium (15-20 min)", "Long (20-25 min)" |
| Sort | Single-select | Dropdown: Popular, Highest Rated, Newest, Alphabetical |

### Navigation Structure

```
Homepage
├── Featured works (editorially curated, rotated)
├── Genre grid (16 cards, one per genre, with work count)
├── Recently published (latest 12 works across all genres)
└── "Surprise me" (random work)

Browse (/browse)
├── All works with filter bar
├── Genre landing pages (/browse/science-fiction)
│   ├── Genre description + stats
│   ├── Subgenre navigation
│   └── Top-rated in genre
└── Subgenre pages (/browse/science-fiction/cyberpunk)
    ├── All works in subgenre
    └── Author combination explorer

Work page (/work/the-glass-apprentice)
├── Reading view (the text)
├── Formula card (authorA × authorB | workX × workY)
├── Reviews section
└── "More like this" (same subgenre, overlapping authors/works)

Persona page (/persona/lit-fic-047-adaeze)
├── Persona profile
├── All reviews by this persona
└── Rating distribution
```

---

## 12. TTS Optimization

Every reading page must be parseable by Speechify and ElevenReader. These apps use Readability.js-style extraction.

### Required HTML Structure

```html
<article lang="en">
  <header>
    <h1>{title}</h1>
    <p class="byline">{genre} / {subgenre}</p>
    <p class="formula">
      Combining {authorA} + {authorB} | {workX} + {workY}
    </p>
    <time datetime="{publishedDate}">{formattedDate}</time>
  </header>

  <section class="reading-content">
    <p>First paragraph...</p>
    <p>Second paragraph...</p>
    <!-- Scene breaks use <hr>, not visual-only markers -->
    <hr />
    <p>New scene...</p>
  </section>
</article>

<!-- Reviews and metadata OUTSIDE <article> so TTS skips them -->
<aside aria-label="Reviews and ratings">
  ...
</aside>
```

### TTS Meta Tags

```html
<meta name="author" content="{authorA} x {authorB} style">
<meta property="og:type" content="article">
<meta property="article:published_time" content="{isoDate}">
<link rel="next" href="/work/{next-slug}">
<link rel="prev" href="/work/{prev-slug}">
```

### TTS-Friendly Content Rules

1. Use `<em>` not `<i>`, `<strong>` not `<b>`
2. Use actual em dashes, not double hyphens
3. Use `<abbr title="...">` for any abbreviations
4. Declare `lang` attributes on foreign-language passages
5. Scene breaks use `<hr>` elements, not decorative text in paragraphs
6. No inline UI elements (icons, buttons) within `<article>`

---

## 13. Git Workflow & Automation

### Branch Naming

```
content/<combination-id>          # e.g., content/sf-cyber-001
persona/<genre>                   # e.g., persona/literary-fiction
infra/<feature>                   # e.g., infra/search-index
fix/<description>                 # e.g., fix/dark-mode-contrast
```

### Commit Message Format

```
<type>(<scope>): <description>

<body>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

Types: `feat`, `fix`, `content`, `persona`, `review`, `infra`, `docs`, `style`
Scopes: `site`, `content`, `persona`, `pipeline`, `ci`

### Issue Templates

Every work gets a GitHub Issue before generation begins:

```markdown
---
name: New Work
about: Track generation of a single work
title: "[CONTENT] {combination-id}: {title}"
labels: content, {genre}, {subgenre}
---

## Combination
- **ID**: {combination-id}
- **Genre**: {genre} / {subgenre}
- **Author A**: {authorA}
- **Author B**: {authorB}
- **Work X**: {workX}
- **Work Y**: {workY}

## Checklist
- [ ] Combination spec reviewed
- [ ] Work generated
- [ ] Self-review pass
- [ ] Revision complete
- [ ] Schema validation
- [ ] Quality review
- [ ] Reviews generated
- [ ] PR opened
- [ ] PR merged
- [ ] Live on site
```

### PR Auto-Merge Rules

PRs auto-merge when:
- All CI checks pass (schema, word count, banned names, rating consistency)
- No quality flags raised by AI reviewer
- At least one approval (can be from the Claude Code GitHub Action reviewer)

---

## 14. GitHub Actions & Deployment

### Deploy Workflow

GitHub Pages is configured to serve from the `docs/` folder on the `main` branch. The CI workflow builds the Astro site into `docs/` and commits the result.

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'astro.config.mjs'
      - 'package.json'
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npm run build  # Outputs to docs/
      - name: Commit docs/ if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/
          git diff --staged --quiet || git commit -m "build: update docs/ from ${{ github.sha }}"
          git push
```

### Content Validation Workflow

```yaml
# .github/workflows/validate-content.yml
name: Validate Content

on:
  pull_request:
    paths:
      - 'src/content/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npm run build  # Astro validates schemas at build time
      - run: npm run validate:wordcount
      - run: npm run validate:banned-names
      - run: npm run validate:ratings
```

### Claude Code PR Review

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - 'src/content/works/**'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: "--model claude-opus-4-6 --max-turns 5"
          prompt: |
            Review this new work for:
            1. Does the prose reflect the four sources in the combination formula?
            2. Is it a complete, satisfying read with beginning/middle/end?
            3. Does it respect genre conventions while being distinctive?
            4. Are there any AI-isms (hedging, list-like prose, hollow superlatives)?
            5. Do the reviews reference specific passages from the text?
            Approve if quality is high. Request changes with specific feedback if not.
```

---

## 15. Claude Code CLI Workflow

### Session Types

| Task | Mode | Command |
|------|------|---------|
| Generate one work | Headless + worktree | `claude -w "work-{id}" -p "..." --model claude-opus-4-6` |
| Generate reviews | Headless + worktree | `claude -w "work-{id}" -p "..."` (continue in same worktree) |
| Build personas | Headless | `claude -p "..." --output-format json` |
| Quality review | Headless | `claude -p "..." --model claude-opus-4-6` |
| Bulk generation | Fan-out script | `for id in $(cat queue.json \| jq -r '.[].id'); do ... done` |
| Interactive work | Interactive + worktree | `claude -w feature-name` |
| Agent team | Experimental | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude` |

### Cross-Context-Window Continuity

Each generation script must be self-contained — a fresh Claude instance should be able to pick up any work at any stage by reading:

1. The combination spec in `manifests/combination-matrix/<genre>.json`
2. The generation template in `templates/work-generation.md`
3. The genre context in `GENRE_TAXONOMY.md`
4. The work's current state (if resuming) in `src/content/works/<path>`
5. The CLAUDE.md in the site repo root

No implicit context. No "you should remember from last time." Every invocation starts from files.

### Parallelism

Run up to 5 concurrent worktrees for content generation:

```bash
# scripts/batch-generate.sh
QUEUE=$(cat manifests/generation-queue.json | jq -r '.[0:5].[].id')
for COMBO_ID in $QUEUE; do
  ./scripts/generate-work.sh "$COMBO_ID" &
done
wait
```

Each worktree is fully isolated. Merge conflicts are impossible because each work has a unique file path.

---

## 16. Scaling Strategy

### Phase 1: Foundation (Weeks 1-4)

- Build the Astro site skeleton with all layouts, components, and styles
- Create the content schema and validation pipeline
- Generate the first 10 reader personas for 3 genres (literary fiction, SF, fantasy)
- Generate the first 5 works (1-2 per genre) as golden examples
- Set up GitHub Actions for deploy and validation
- Publish the site with the initial 5 works

### Phase 2: Pipeline Hardening (Weeks 5-8)

- Refine generation prompts based on golden example quality
- Build all automation scripts (generate, review, rate, publish)
- Generate combination matrices for all 16 genres
- Create persona pools for all 16 genres (~1,600 personas)
- Generate 50-100 works across all genres (3-6 per genre)
- Tune the quality review agent

### Phase 3: Scale (Weeks 9+)

- Parallel generation: 5 concurrent worktrees, 20-40 works/day
- Continuous deployment: works go live within hours of generation
- Monitor quality metrics, adjust prompts as patterns emerge
- Target: 500 works/month until 13,000 reached

### Content Ordering Priority

1. Generate at least 1 golden example per subgenre first (establishes the template)
2. Then round-robin across subgenres, favoring underrepresented genres
3. Never complete a genre before all genres have at least 10 works
4. Surface the most-reviewed, highest-rated works on the homepage

---

## 17. Open Questions

> These need resolution before implementation begins. Each should become a decision documented in this spec.

1. **Cover images?** Should works have generated cover art? If so, what tool (DALL-E, Midjourney via API, Stable Diffusion)? This significantly impacts visual richness but adds complexity.

2. **Reading lists / bookshelves?** Should the site support localStorage-based "want to read" / "have read" lists a la Goodreads? No backend needed, but adds client-side JS complexity.

3. **Content licensing?** What license applies to the generated works? Creative Commons? Public domain? This affects the site footer and metadata.

4. **Custom domain?** The site lives at `must-read.github.io`. Should it also have a custom domain like `mustread.pub`?

5. **Analytics?** Any privacy-respecting analytics (Plausible, Fathom) to track which genres/works are most read? Useful for guiding generation priority.

6. **RSS / Atom feed?** A feed of new works would let readers subscribe. Easy to generate at build time with Astro.

7. **Combination transparency?** Should the formula (authorA x authorB | workX x workY) be visible to readers on the work page? It's an interesting feature but might break immersion for some readers. Could be a toggleable "behind the scenes" section.

8. **Persona profiles as a feature?** Should reader personas have browsable profile pages showing all their reviews? This adds a social-media-like discovery layer but requires more pages (1,600 persona pages).

9. **Build time at scale?** With 13,000 markdown files, Astro build time could become significant. Need to test with 1,000 files and extrapolate. May need incremental builds or content sharding.