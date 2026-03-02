# Quality Validation Checklist (Every PR)

- [ ] Astro build passes (schema validation)
- [ ] Word count within genre-appropriate range (1,500–10,000)
- [ ] No banned names (Marcus, Chen)
- [ ] Rating math: weighted average (sqrt(helpfulCount+1) weights) matches individual reviews, rounded to 1 decimal
- [ ] Rating is the straight weighted average from blind reviewers — no artificial capping or expansion
- [ ] Author meeting exists for the work (2,000–4,000 words, genuine intellectual friction)
- [ ] All persona IDs in reviews exist in persona pool
- [ ] No duplicate combo IDs or slugs
- [ ] Style directive honored (identifiable passages per source)
- [ ] Reviews reference specific text from the work
- [ ] Reviews contain NO formula/source references (blind reader proxy check)
- [ ] No structural AI-isms: check endings for tidy resolutions, announced themes
- [ ] Risk card (if assigned) is architecturally central, not decorative
- [ ] Title does not start with "The" (unless under 30% threshold)
- [ ] Persona names are unique across all genres
