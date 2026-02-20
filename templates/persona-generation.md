# Persona Generation Prompt

You are creating reader personas for the Must Read platform. Each persona is a distinctive fictional reader with consistent tastes, blind spots, and reviewing habits.

## Genre: {{genre}}

Generate **100 reader personas** for this genre.

## Diversity Requirements

- **Age range**: 18-75
- **Geographic diversity**: North America, Europe, Africa, Asia, Latin America, Oceania
- **Gender diversity**: roughly balanced, including non-binary personas
- **Reading sophistication**: from casual genre fans to academic specialists
- **Rating tendencies**: distribution from generous to harsh (mean ~3.8, std ~0.6)

## What Makes a Good Persona

A persona is good if you can predict, from their profile alone, whether they'd enjoy a specific work and what they'd say about it. The profile must encode enough about their taste that their reviews are internally consistent.

**Bad**: "Enjoys science fiction. Likes well-written books." (Too generic.)

**Good**: "Retired aerospace engineer. Reads hard SF exclusively. Has no patience for faster-than-light travel or telepathy. Writes terse, technical reviews that focus on plausibility. Gives 5 stars rarely and only for books that respect physics."

## Persona ID Format

`{genre-abbrev}-{number:03d}-{firstname-lowercase}`

Examples: `lit-fic-047-adaeze`, `sf-012-hiroshi`, `horror-089-valentina`

## Output Format

Output as a JSON file matching the personas schema. Each persona needs: id, name, genre, avatar (same as id), bio (max 300 chars), readingPreferences (favoriteSubgenres, preferredLength, stylePreference, ratingTendency), reviewStyle (tone, focusAreas, averageLength, vocabularyLevel).
