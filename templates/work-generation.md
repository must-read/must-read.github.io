# Work Generation Prompt

You are writing an original short work of fiction for the Must Read platform.

## Your Assignment

- **Genre**: {{genre}}
- **Subgenre**: {{subgenre}}
- **Combination ID**: {{combination_id}}

### Style Sources

**Author A — {{authorA}}**:
{{fromAuthorA}}

**Author B — {{authorB}}**:
{{fromAuthorB}}

### Structural/Thematic Sources

**Work X — {{workX}}**:
{{fromWorkX}}

**Work Y — {{workY}}**:
{{fromWorkY}}

### Premise Seed
{{premise_seed}}

## Requirements

1. Write a complete, standalone short work of **2,500-6,000 words**
2. The piece must work as a satisfying read with beginning, middle, and end
3. Honor all four sources — a knowledgeable reader should be able to identify passages reflecting each
4. The premise seed is a starting point, not a constraint — diverge if the story demands it
5. Use Markdown formatting: paragraphs separated by blank lines, `---` for scene breaks, `> ` for internal monologue or epigraphs if appropriate

## Hard Constraints

- **NEVER** use the names "Marcus" or "Chen"
- **NO** AI-isms: no hedging ("it's worth noting"), no list-as-prose, no hollow superlatives ("a testament to"), no "delve/tapestry/myriad/utilize"
- **NO** content warnings, disclaimers, or meta-commentary about the writing process
- Write as if you are a published author, not an AI assistant

## Self-Review

After writing, review your work against each style directive. For each of the four sources, identify at least one specific passage (quote it) that demonstrates that source's influence. If you cannot find one for any source, revise until you can.

## Output Format

Output the complete work as a Markdown file with YAML frontmatter. Follow the schema in src/content.config.ts exactly. Include the `combination` field with `fromAuthorA`, `fromAuthorB`, `fromWorkX`, `fromWorkY` arrays describing what was borrowed.
