# Content Generation Rules

These rules apply to ALL content generated for the Must Read platform.

## Word Count & Length

- **Range**: 1,500–10,000 words per work (6–40 min read)
- Lengths sampled from genre-specific probabilistic distributions in `scripts/word-count-distribution.json`
- Each work gets a target word count with a ±300 word window
- Horror and humor skew shorter; fantasy and historical skew longer
- A generation batch should show genuine variety — not all 4,000-word stories

## Prose Quality

- **Banned names**: Never use "Marcus" or "Chen" in generated content
- **No AI-isms (prose)**: No hedging, lists-as-prose, hollow superlatives, or "delve/tapestry/testament" filler
- **No AI-isms (structural)**: No too-neat three-act structure, no tidy epiphanies, no every-thread-resolved endings, no announced themes, no symmetrical bookends, no balanced-perspectives-on-all-sides

## Formula Adherence

Every piece must demonstrably reflect all four sources (authorA, authorB, workX, workY) with identifiable passages.

## Ratings & Reviews

- **Rating scale**: 1–5 integer per individual review
- **Aggregate**: Weighted average using `rating = Σ(rating_i * sqrt(helpfulCount_i + 1)) / Σ(sqrt(helpfulCount_i + 1))`, rounded to 1 decimal
- **No artificial capping or expansion** — the weighted average IS the final rating
- **Distribution**: Plenty of 3s, healthy number of 2s, some 5s, occasional 1s. NOT everything is 4 stars
- **Review count**: 7–12 reviews per work (natural spread, NOT always 10)
- **Review length**: 50–1000 chars per schema. Most reviews 200–600 chars. Natural variation
- **Review dates**: Within the past ~7 months. Natural spread — NOT all on the same day
- **Helpful votes**: `helpfulCount` 0–100 with organic distribution. Most cluster in 0–20; a few outliers reach higher

## Blind Reviews (CRITICAL)

Reviewers are **blind reader proxies**. They receive ONLY the finished work and their persona profile. NO combination formula, NO source author info, NO knowledge of how the story was constructed. They react as real readers.

## Genre Splattering

Generate round-robin across subgenres, never completing one genre while others are empty.

## Title Variety

No more than 30% of titles should start with "The". Vary title structures — single words, phrases, names, questions, imperatives, compound forms, possessives, gerunds, etc.

## Risk Cards

~30% of works receive a risk card (structural constraint from `templates/risk-cards.md`). When assigned, the constraint is MANDATORY and must be architecturally central, not decorative. Cards are not reused within the same batch.

## Personas

- Persona first names must be unique across the entire platform, not just within a genre
- Each persona's reviews must match their documented preferences, tone, and rating tendency

## Pitch Pipeline (Temporary)

1 pitched story for every 3 non-pitched stories. Pitched stories go through the FULL pipeline with no shortcuts. After all pitches are completed, archive the `pitches/` directory.
