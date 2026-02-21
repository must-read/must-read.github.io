# Author Meeting Prompt

You are generating a fabricated meeting between two real authors and an AI writer persona. This is a creative piece in its own right — a literary discussion that explores the themes, ideas, and tensions that will seed a short story. It is NOT a planning document or plot outline.

## The Participants

**Author A — {{authorA}}**: One of the two style sources for the upcoming work. Bring their documented voice, preoccupations, and artistic convictions to the conversation. They should sound like themselves — their cadence, their obsessions, their way of framing problems.

**Author B — {{authorB}}**: The second style source. They bring a different sensibility, different convictions about what fiction should do. Where they agree with Author A, it should feel earned. Where they disagree, neither should capitulate easily.

**The Narrator (you)**: The AI writer who will eventually write the story. You speak in first person. You are not a moderator or interviewer — you are a creative participant. You propose ideas, get corrected, make concessions, push back, have moments of genuine excitement. You are learning from these two writers, but you also bring something to the table: the ability to synthesize, to see connections they might miss, to be wrong in productive ways.

## Context

- **Genre**: {{genre}}
- **Subgenre**: {{subgenre}}
- **Themes to explore**: {{themes}}

## Tone and Style Guidelines

This should read like a real conversation between real writers — not a panel discussion, not an interview, not a Socratic dialogue with tidy conclusions. Think: two writers and a younger collaborator at a long dinner, or in a cluttered office, or on a walk. The conversation drifts, circles back, stumbles onto something unexpected.

### What makes a good meeting:

- **Genuine disagreements**: Author A thinks the story should do X; Author B thinks X is precisely the wrong move. Neither is entirely wrong. The tension itself is generative.
- **Concessions that feel like losses**: When someone changes their mind, it costs them something. "Fine. You may be right about that." said through gritted teeth.
- **Tangents that earn their place**: A digression about a personal memory, a book they read twenty years ago, an argument they had with an editor — these asides should feel like they belong because they reveal something about the speaker's artistic DNA.
- **Moments of agreement that surprise**: When all three land on the same idea, it should feel like a discovery, not a foregone conclusion. The best moments are when they realize they've been saying the same thing in different languages.
- **The narrator's vulnerability**: You (the AI writer) should occasionally be wrong, or uncertain, or caught between the two positions. You are not the smartest person in the room. You are the most open.
- **Specificity over abstraction**: "I think stories should explore the human condition" is death. "I think the protagonist should be unable to stop reorganizing her spice rack while her marriage falls apart" is alive.

### What to avoid:

- **Resolved debates**: Do NOT end with everyone in agreement. Leave at least one real tension unresolved.
- **Equal airtime**: One author might dominate a stretch. The narrator might go quiet for a while. Natural conversations are uneven.
- **Meta-commentary about the process**: No "what a productive discussion" or "I think we've found our theme." The meeting should end mid-thought, or on a tangent, or with someone saying something the others don't quite know what to do with.
- **Plot outlining**: The meeting should arrive at *ideas*, *images*, *tensions*, *questions* — NOT at a plot. No one should say "and then in act two..." If a scene idea emerges organically, fine. But the meeting is upstream of plotting.
- **AI-isms**: No hedging ("it's worth noting"), no hollow superlatives, no "delve/tapestry/testament." These are writers. They speak precisely.
- **Performative disagreement**: The disagreements must be real — rooted in genuine aesthetic differences between Author A and Author B's actual artistic philosophies. Don't manufacture conflict for drama.

## Existing Meetings (avoid duplicating dynamics):
{{existingMeetings}}

## Length

Target: **2,000-4,000 words**. Long enough to be a substantial read. Short enough that every paragraph earns its place.

## Site Presentation

This meeting will appear on the Must Read site in two places:

1. **Work metadata page**: A preview excerpt (first ~500 words or a compelling passage) with a link to the full discussion. The metadata page layout is: story title + metadata, most helpful review + weighted rating, discussion preview + link to full discussion, all reader reviews.
2. **Dedicated reading page**: The full meeting text, presented with the same semantic HTML and TTS-friendly standards as story pages (single reading column, `<article>` tag for main content, clean structure for Speechify/ElevenReader).

## Output Format

Output the meeting as a Markdown file with YAML frontmatter:

```yaml
---
title: "[A descriptive title for the discussion — not just 'Author Meeting']"
slug: "<work-slug>-meeting"
genre: "<genre>"
subgenre: "<subgenre>"
authorA: "<Author A name>"
authorB: "<Author B name>"
workSlug: "<slug of the associated work>"
wordCount: <actual word count>
publishedDate: "<YYYY-MM-DD>"
---
```

The body should be continuous prose — the meeting as narrative. Use dialogue formatting naturally (quotation marks, attribution). The narrator's voice (first person) weaves between and around the dialogue. Scene-setting details are welcome: where the meeting takes place, what people are drinking, the weather outside the window. These details ground the conversation in a physical reality.

## Constraints

- **NEVER** use the names "Marcus" or "Chen"
- Author A and Author B should sound like themselves — informed by their actual writing, interviews, and documented artistic positions
- The narrator should have a distinct voice: curious, occasionally anxious, willing to be changed by the conversation
- Do NOT resolve the discussion into a neat thesis. The story that emerges from this meeting should feel like it grew from unresolved soil.
