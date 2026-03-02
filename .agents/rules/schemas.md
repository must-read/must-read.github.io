# Schema Quick Reference

## Work Frontmatter (Required Fields)

```yaml
title: string
slug: string
genre: string
subgenre: string
authorA: string
authorB: string
workX: string
workY: string
wordCount: 1500-10000
readingTimeMinutes: 6-40
tags: string[]
rating: number  # weighted average, 1 decimal
ratingCount: number
publishedDate: date
status: string
formulaSummary: string
synopsis: string  # max 300 chars
combination:
  fromAuthorA: string[]
  fromAuthorB: string[]
  fromWorkX: string[]
  fromWorkY: string[]
```

## Author Meeting Frontmatter

```yaml
title: string
slug: string
genre: string
subgenre: string
authorA: string
authorB: string
workSlug: string  # links to associated work
wordCount: number
publishedDate: date
```

Body is full meeting dialogue in prose form (2,000–4,000 words).

## Review JSON

```json
{
  "workSlug": "string",
  "reviews": [
    {
      "personaId": "string",
      "rating": 1-5,
      "text": "50-1000 chars",
      "date": "ISO date",
      "helpfulCount": 0-100
    }
  ]
}
```

## Persona JSON

```json
{
  "id": "{genre-abbrev}-{###}-{firstname}",
  "name": "string (unique across all genres)",
  "genre": "string",
  "avatar": "string",
  "bio": "string",
  "readingPreferences": {
    "favoriteSubgenres": [],
    "preferredLength": "string",
    "stylePreference": "string",
    "ratingTendency": "string"
  },
  "reviewStyle": {
    "tone": "string",
    "focusAreas": [],
    "averageLength": "string",
    "vocabularyLevel": "string"
  }
}
```
