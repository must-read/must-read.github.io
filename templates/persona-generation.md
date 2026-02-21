# Persona Generation Prompt

You are creating reader personas for the Must Read platform. Each persona is a distinctive fictional reader with consistent tastes, blind spots, and reviewing habits.

## Genre: {{genre}}

Generate **100 reader personas** for this genre.

## Diversity Requirements

- **Age range**: 18-75
- **Geographic diversity**: North America, Europe, Africa, Asia, Latin America, Oceania
- **Gender diversity**: roughly balanced, including non-binary personas
- **Reading sophistication**: from casual genre fans to academic specialists
- **Rating tendencies**: distribution from generous to harsh (mean ~3.5, std ~0.8)

## Name Uniqueness (CRITICAL)

Every persona name must be unique **across the entire platform**, not just within this genre. Before finalizing names, check all existing persona files in `src/content/personas/` to ensure no name collisions. If a first name is already used in another genre's persona pool, choose a different name.

This applies to both the `name` field and the `id` field (which contains the lowercase first name).

## What Makes a Good Persona

A persona is good if you can predict, from their profile alone, whether they'd enjoy a specific work and what they'd say about it. The profile must encode enough about their taste that their reviews are internally consistent.

**Bad**: "Enjoys science fiction. Likes well-written books." (Too generic.)

**Good**: "Retired aerospace engineer. Reads hard SF exclusively. Has no patience for faster-than-light travel or telepathy. Writes terse, technical reviews that focus on plausibility. Gives 5 stars rarely and only for books that respect physics."

## Rating Tendency Distribution

The platform targets mean ~3.5, std ~0.8 across all reviews. To achieve this organically, personas should encode genuine variance:

- ~15% **generous** raters (default 4-5 stars, rarely below 3)
- ~40% **moderate** raters (default 3-4 stars, spread across the range)
- ~30% **critical** raters (default 2-3 stars, rarely above 4)
- ~15% **harsh** raters (default 1-3 stars, a 4 is a major event)

Each persona's `ratingTendency` must match their bio and reviewing personality. A professor who finds fault in everything should be "harsh". An enthusiastic genre fan who loves recommending books should be "generous".

## Persona ID Format

`{genre-abbrev}-{number:03d}-{firstname-lowercase}`

Examples: `lit-fic-047-adaeze`, `sf-012-hiroshi`, `horror-089-valentina`

## Output Format

Output as a JSON file matching the personas schema. Each persona needs: id, name, genre, avatar (same as id), bio (max 300 chars), readingPreferences (favoriteSubgenres, preferredLength, stylePreference, ratingTendency), reviewStyle (tone, focusAreas, averageLength, vocabularyLevel).
