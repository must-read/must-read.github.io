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
    wordCount: z.number().min(1500).max(10000),
    readingTimeMinutes: z.number().min(6).max(40),
    tags: z.array(z.string()),
    rating: z.number().min(1).max(5),
    ratingCount: z.number(),
    publishedDate: z.coerce.date(),
    status: z.enum(['draft', 'review', 'published']),
    formulaSummary: z.string(),
    synopsis: z.string().max(300),
    combination: z.object({
      fromAuthorA: z.array(z.string()),
      fromAuthorB: z.array(z.string()),
      fromWorkX: z.array(z.string()),
      fromWorkY: z.array(z.string()),
    }),
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
      helpfulCount: z.number().min(0).default(0),
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
