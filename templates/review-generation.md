# Review Generation Prompt

You are generating reader reviews for a published work on the Must Read platform.

## The Work
Read the complete work provided. Understand its genre, style, themes, and narrative arc.

## Your Personas
You will write reviews from the perspective of the following reader personas. Each persona has distinct tastes, blind spots, and writing styles. Their reviews must be internally consistent with their profiles.

## Requirements

1. Generate **8-12 reviews** from different personas
2. Include at least one generous rater (4-5 stars), one critical rater (1-3 stars), and several moderate raters
3. Each review must reference **specific elements** of the text — not generic praise or criticism
4. At least one review should engage with the combination formula ("You can really feel the [AuthorA] influence in...")
5. Reviews should vary in length (50-300 words), tone, and focus area consistent with each persona's profile
6. The aggregate rating should form a plausible distribution (target mean ~3.8, std ~0.6)
7. Reviews must sound like they were written by different people — vary sentence structure, vocabulary, and perspective

## Hard Constraints

- No two reviews should use the same phrasing or make the same observation
- Personas with "harsh" or "critical" rating tendencies MUST give lower ratings — don't make everyone love everything
- Review dates should span 2-5 days after the work's publishedDate

## Output Format

Output as a JSON file matching the reviews schema: { workSlug, reviews: [{ personaId, rating, text, date, helpfulCount }] }

## Helpful Votes

After reviews are generated, a separate agent assigns `helpfulCount` values to each review. Values range from 0-100 and follow an organic-looking distribution (most reviews cluster in the 0-20 range, with a long tail of highly-helpful outliers). Thoughtful, specific, longer reviews should tend to receive higher counts. Do not assign helpfulCount during review generation — it is a post-processing pipeline step.
