#!/usr/bin/env node

/**
 * compile-content.js
 *
 * Reads all published works from the Must Read project and assembles
 * one markdown file per genre volume. Each volume includes front matter,
 * table of contents, and all works with their full apparatus (synopsis,
 * rating block, formula, author meeting, story text, reader reviews).
 *
 * Usage: node publishing/scripts/compile-content.js
 */

const fs = require('fs');
const path = require('path');
const matter = require('gray-matter');

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const PROJECT_ROOT = path.resolve(__dirname, '..', '..');
const CONTENT_DIR = path.join(PROJECT_ROOT, 'src', 'content');
const OUTPUT_DIR = path.join(PROJECT_ROOT, 'publishing', 'compiled');

const WORKS_DIR = path.join(CONTENT_DIR, 'works');
const REVIEWS_DIR = path.join(CONTENT_DIR, 'reviews');
const MEETINGS_DIR = path.join(CONTENT_DIR, 'meetings');
const PERSONAS_DIR = path.join(CONTENT_DIR, 'personas');

const GENRE_DISPLAY_NAMES = {
  'adventure': 'Adventure',
  'creative-nonfiction': 'Creative Nonfiction',
  'crime-noir': 'Crime Noir',
  'dystopian': 'Dystopian',
  'fantasy': 'Fantasy',
  'gothic-fiction': 'Gothic Fiction',
  'historical-fiction': 'Historical Fiction',
  'horror': 'Horror',
  'humor-satire': 'Humor & Satire',
  'literary-fiction': 'Literary Fiction',
  'magical-realism': 'Magical Realism',
  'mystery-thriller': 'Mystery & Thriller',
  'philosophical-fiction': 'Philosophical Fiction',
  'romance': 'Romance',
  'science-fiction': 'Science Fiction',
  'western': 'Western',
};

// Alphabetical order determines volume number
const GENRE_ORDER = Object.keys(GENRE_DISPLAY_NAMES).sort();

const GENRE_SUBTITLES = {
  'adventure': 'Horizons of Salt, Powder, and Unspent Nerve',
  'creative-nonfiction': 'Testimony of the Actual and the Almost True',
  'crime-noir': 'Confessions in Smoke, Neon, and Borrowed Time',
  'dystopian': 'Blueprints of the Permissible and the Erased',
  'fantasy': 'Kingdoms of Ink, Iron, and Impossible Light',
  'gothic-fiction': 'Houses That Remember What the Living Forget',
  'historical-fiction': 'The Weight of Centuries in a Single Room',
  'horror': 'What Watches from the Corner of the Familiar',
  'humor-satire': 'The Precision of Absurdity, Lovingly Applied',
  'literary-fiction': 'Sentences That Know More Than Their Speakers',
  'magical-realism': 'Where the Ordinary Insists on Being Otherwise',
  'mystery-thriller': 'The Architecture of Suspicion and Delayed Truth',
  'philosophical-fiction': 'Premises the Mind Cannot Refuse to Enter',
  'romance': 'The Calculus of Longing and the Algebra of Need',
  'science-fiction': 'Futures Measured in Light-Years and Human Error',
  'western': 'Dust, Distance, and the Morality of Open Ground',
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Convert a numeric rating (0-5) to a star string.
 * Whole stars only: rounds to nearest integer.
 * e.g. 4 -> "★★★★☆", 3 -> "★★★☆☆"
 */
function ratingToStars(rating) {
  // Numeric rating display — clean, universal, literary
  return `${rating}/5`;
}

/**
 * Format a subgenre slug into a display heading.
 * e.g. "exploration-lost-world" -> "Exploration & Lost World"
 *      "classic-victorian-gothic" -> "Classic Victorian Gothic"
 *      "soft-sf-social-sf" -> "Soft SF & Social SF"
 */
function formatSubgenre(slug) {
  return slug
    .split('-')
    .map((word) => {
      if (word === 'sf') return 'SF';
      if (word === 'and') return '&';
      return word.charAt(0).toUpperCase() + word.slice(1);
    })
    .join(' ');
}

/**
 * Recursively find all files matching an extension under a directory.
 */
function findFiles(dir, ext) {
  const results = [];
  if (!fs.existsSync(dir)) return results;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...findFiles(fullPath, ext));
    } else if (entry.name.endsWith(ext)) {
      results.push(fullPath);
    }
  }
  return results;
}

/**
 * Format a date string (YYYY-MM-DD) into a readable form.
 */
function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return String(dateStr);
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

// ---------------------------------------------------------------------------
// Data Loading
// ---------------------------------------------------------------------------

/**
 * Load all persona JSON files into a map keyed by persona ID.
 */
function loadPersonas() {
  const map = new Map();
  const files = findFiles(PERSONAS_DIR, '.json');
  for (const filePath of files) {
    try {
      const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      if (data.id) {
        map.set(data.id, data);
      }
    } catch (err) {
      console.warn(`  [WARN] Could not parse persona: ${filePath} — ${err.message}`);
    }
  }
  return map;
}

/**
 * Load all review JSON files into a map keyed by workSlug.
 */
function loadReviews() {
  const map = new Map();
  const files = findFiles(REVIEWS_DIR, '.json');
  for (const filePath of files) {
    try {
      const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      if (data.workSlug && Array.isArray(data.reviews)) {
        map.set(data.workSlug, data.reviews);
      }
    } catch (err) {
      console.warn(`  [WARN] Could not parse reviews: ${filePath} — ${err.message}`);
    }
  }
  return map;
}

/**
 * Load all meeting markdown files into a map keyed by workSlug.
 * Returns { title, content } for each.
 */
function loadMeetings() {
  const map = new Map();
  const files = findFiles(MEETINGS_DIR, '.md');
  for (const filePath of files) {
    try {
      const raw = fs.readFileSync(filePath, 'utf-8');
      const { data: fm, content } = matter(raw);
      if (fm.workSlug) {
        map.set(fm.workSlug, {
          title: fm.title || 'Author Meeting',
          content: content.trim(),
        });
      }
    } catch (err) {
      console.warn(`  [WARN] Could not parse meeting: ${filePath} — ${err.message}`);
    }
  }
  return map;
}

/**
 * Load all published works, grouped by genre.
 * Returns a Map<genreSlug, Work[]> where each Work has
 * { frontmatter, body, filePath }.
 */
function loadWorks() {
  const genreMap = new Map();
  const files = findFiles(WORKS_DIR, '.md');
  for (const filePath of files) {
    try {
      const raw = fs.readFileSync(filePath, 'utf-8');
      const { data: fm, content } = matter(raw);

      if (fm.status !== 'published') continue;

      const genre = fm.genre;
      if (!genre) continue;

      if (!genreMap.has(genre)) {
        genreMap.set(genre, []);
      }
      genreMap.get(genre).push({
        frontmatter: fm,
        body: content.trim(),
        filePath,
      });
    } catch (err) {
      console.warn(`  [WARN] Could not parse work: ${filePath} — ${err.message}`);
    }
  }

  // Sort each genre's works by rating descending (best first)
  for (const [genre, works] of genreMap) {
    works.sort((a, b) => (b.frontmatter.rating || 0) - (a.frontmatter.rating || 0));
  }

  return genreMap;
}

// ---------------------------------------------------------------------------
// Volume Assembly
// ---------------------------------------------------------------------------

/**
 * Build the formula section for a work.
 */
function buildFormulaSection(fm) {
  const lines = [];
  lines.push('### The Formula');
  lines.push('');
  lines.push(`**${fm.authorA}** (style) + **${fm.authorB}** (style) + *${fm.workX}* (structure) + *${fm.workY}* (themes)`);
  lines.push('');

  if (fm.formulaSummary) {
    lines.push(fm.formulaSummary.trim());
    lines.push('');
  }

  const combo = fm.combination;
  if (combo) {
    if (combo.fromAuthorA && combo.fromAuthorA.length > 0) {
      lines.push(`**From ${fm.authorA}:**`);
      for (const item of combo.fromAuthorA) {
        lines.push(`- ${item}`);
      }
      lines.push('');
    }
    if (combo.fromAuthorB && combo.fromAuthorB.length > 0) {
      lines.push(`**From ${fm.authorB}:**`);
      for (const item of combo.fromAuthorB) {
        lines.push(`- ${item}`);
      }
      lines.push('');
    }
    if (combo.fromWorkX && combo.fromWorkX.length > 0) {
      lines.push(`**From *${fm.workX}*:**`);
      for (const item of combo.fromWorkX) {
        lines.push(`- ${item}`);
      }
      lines.push('');
    }
    if (combo.fromWorkY && combo.fromWorkY.length > 0) {
      lines.push(`**From *${fm.workY}*:**`);
      for (const item of combo.fromWorkY) {
        lines.push(`- ${item}`);
      }
      lines.push('');
    }
  }

  return lines.join('\n');
}

/**
 * Build the rating block: weighted rating + most helpful review.
 */
function buildRatingBlock(fm, reviews, personas) {
  const lines = [];
  lines.push('### Rating');
  lines.push('');

  const ratingDisplay = fm.rating != null ? Number(fm.rating).toFixed(1) : '—';
  lines.push(`**${ratingDisplay}/5** (${fm.ratingCount || reviews.length} reviews)`);
  lines.push('');

  if (reviews.length > 0) {
    // Find most helpful review (highest helpfulCount)
    const mostHelpful = reviews.reduce((best, r) =>
      (r.helpfulCount || 0) > (best.helpfulCount || 0) ? r : best
    , reviews[0]);

    const persona = personas.get(mostHelpful.personaId);
    const reviewerName = persona ? persona.name : mostHelpful.personaId;
    const reviewStars = ratingToStars(mostHelpful.rating);

    lines.push(`> ${reviewStars}`);
    lines.push(`>`);
    // Wrap review text in blockquote, preserving line breaks
    const reviewLines = mostHelpful.text.split('\n');
    for (const rl of reviewLines) {
      lines.push(`> ${rl}`);
    }
    lines.push(`>`);
    lines.push(`> — **${reviewerName}** · ${formatDate(mostHelpful.date)} · ${mostHelpful.helpfulCount || 0} found this helpful`);
    lines.push('');
  }

  return lines.join('\n');
}

/**
 * Build the reader reviews section (all reviews except the most helpful).
 */
function buildReaderReviews(reviews, personas) {
  if (reviews.length <= 1) return '';

  // Find the most helpful review to exclude it
  const mostHelpful = reviews.reduce((best, r) =>
    (r.helpfulCount || 0) > (best.helpfulCount || 0) ? r : best
  , reviews[0]);

  // All other reviews, sorted by helpfulCount descending
  const otherReviews = reviews
    .filter((r) => r !== mostHelpful)
    .sort((a, b) => (b.helpfulCount || 0) - (a.helpfulCount || 0));

  if (otherReviews.length === 0) return '';

  const lines = [];
  lines.push('### Reader Reviews');
  lines.push('');

  for (const review of otherReviews) {
    const persona = personas.get(review.personaId);
    const reviewerName = persona ? persona.name : review.personaId;
    const stars = ratingToStars(review.rating);

    lines.push(`**${reviewerName}** · ${stars} · ${formatDate(review.date)}`);
    lines.push('');
    lines.push(review.text);
    lines.push('');
  }

  return lines.join('\n');
}

/**
 * Build the "Behind the Story" section from the author meeting.
 */
function buildMeetingSection(meeting) {
  const lines = [];
  lines.push('### Behind the Story');
  lines.push('');
  lines.push(`#### ${meeting.title}`);
  lines.push('');
  lines.push(meeting.content);
  lines.push('');
  return lines.join('\n');
}

/**
 * Build the front matter page for a volume.
 */
function buildFrontMatter(genreSlug, volumeNumber) {
  const displayName = GENRE_DISPLAY_NAMES[genreSlug] || genreSlug;
  const subtitle = GENRE_SUBTITLES[genreSlug] || '';

  const lines = [];
  lines.push(`# Must Read · Volume ${volumeNumber} of 16`);
  lines.push(`## ${displayName}`);
  lines.push(`### ${subtitle}`);
  lines.push('');
  lines.push('*Artificium Inter Legere*');
  lines.push('');
  lines.push('---');
  lines.push('');
  lines.push('Everything on this site is fiction generated by Claude Opus 4.6.');
  lines.push('None of the authors named within this site had anything to do');
  lines.push('with the content here. The stories, reviews, personas, meetings,');
  lines.push('and every word on every page are entirely fabricated.');
  lines.push('');
  lines.push('*I am not a lawyer.*');
  lines.push('');
  lines.push('---');
  lines.push('');
  return lines.join('\n');
}

/**
 * Build the table of contents for a volume.
 */
function buildTableOfContents(works) {
  const lines = [];
  lines.push('## Contents');
  lines.push('');

  for (let i = 0; i < works.length; i++) {
    const fm = works[i].frontmatter;
    const anchor = fm.slug;
    const subgenreDisplay = formatSubgenre(fm.subgenre);
    lines.push(`${i + 1}. [${fm.title}](#${anchor}) — *${subgenreDisplay}*`);
  }

  lines.push('');
  lines.push('---');
  lines.push('');
  return lines.join('\n');
}

/**
 * Assemble a single work entry with all its apparatus.
 */
function buildWorkEntry(work, reviews, meeting, personas) {
  const fm = work.frontmatter;
  const lines = [];

  // a. Genre/subgenre heading
  const subgenreDisplay = formatSubgenre(fm.subgenre);
  lines.push(`## ${subgenreDisplay}`);
  lines.push('');

  // Anchor for TOC linking
  lines.push(`<a id="${fm.slug}"></a>`);
  lines.push('');

  // b. Synopsis
  if (fm.synopsis) {
    lines.push('### Synopsis');
    lines.push('');
    lines.push(fm.synopsis.trim());
    lines.push('');
  }

  // c. Rating block (weighted rating + most helpful review)
  if (reviews && reviews.length > 0) {
    lines.push(buildRatingBlock(fm, reviews, personas));
  }

  // d. The Formula
  lines.push(buildFormulaSection(fm));

  // e. Behind the Story (author meeting)
  if (meeting) {
    lines.push(buildMeetingSection(meeting));
  } else {
    console.warn(`  [WARN] No meeting found for work: ${fm.slug}`);
  }

  // f. The Story
  lines.push(`# ${fm.title}`);
  lines.push('');
  lines.push(`*${fm.wordCount.toLocaleString()} words · ${fm.readingTimeMinutes} min read*`);
  lines.push('');
  lines.push(work.body);
  lines.push('');

  // g. Reader Reviews (all except most helpful)
  if (reviews && reviews.length > 1) {
    lines.push(buildReaderReviews(reviews, personas));
  }

  // Separator between works
  lines.push('---');
  lines.push('');

  return lines.join('\n');
}

/**
 * Build the back matter placeholder.
 */
function buildBackMatter() {
  const lines = [];
  lines.push('## Back Matter');
  lines.push('');
  lines.push('<!-- BACK MATTER PLACEHOLDER -->');
  lines.push('<!-- Add acknowledgments, colophon, index, or other back matter here -->');
  lines.push('');
  return lines.join('\n');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

function main() {
  console.log('Must Read — Volume Compiler');
  console.log('===========================');
  console.log('');

  // Ensure output directory exists
  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  // Load all data
  console.log('Loading personas...');
  const personas = loadPersonas();
  console.log(`  ${personas.size} personas loaded`);

  console.log('Loading reviews...');
  const reviewsMap = loadReviews();
  console.log(`  ${reviewsMap.size} review files loaded`);

  console.log('Loading meetings...');
  const meetingsMap = loadMeetings();
  console.log(`  ${meetingsMap.size} meetings loaded`);

  console.log('Loading works...');
  const worksMap = loadWorks();
  let totalWorks = 0;
  for (const works of worksMap.values()) totalWorks += works.length;
  console.log(`  ${totalWorks} published works loaded across ${worksMap.size} genres`);
  console.log('');

  // Compile each genre volume
  let totalWordCount = 0;

  for (let i = 0; i < GENRE_ORDER.length; i++) {
    const genreSlug = GENRE_ORDER[i];
    const volumeNumber = i + 1;
    const displayName = GENRE_DISPLAY_NAMES[genreSlug] || genreSlug;
    const works = worksMap.get(genreSlug);

    if (!works || works.length === 0) {
      console.log(`Volume ${volumeNumber}: ${displayName} — no published works, skipping`);
      continue;
    }

    let genreWordCount = 0;
    for (const w of works) {
      genreWordCount += w.frontmatter.wordCount || 0;
    }
    totalWordCount += genreWordCount;

    console.log(`Volume ${volumeNumber}: ${displayName} — ${works.length} works, ${genreWordCount.toLocaleString()} words`);

    // Assemble volume
    const parts = [];

    // Front matter
    parts.push(buildFrontMatter(genreSlug, volumeNumber));

    // Table of contents
    parts.push(buildTableOfContents(works));

    // Each work with full apparatus
    for (const work of works) {
      const slug = work.frontmatter.slug;
      const reviews = reviewsMap.get(slug) || null;
      const meeting = meetingsMap.get(slug) || null;

      if (!reviews) {
        console.warn(`  [WARN] No reviews found for work: ${slug}`);
      }

      parts.push(buildWorkEntry(work, reviews, meeting, personas));
    }

    // Back matter
    parts.push(buildBackMatter());

    // Write output file
    const outputPath = path.join(OUTPUT_DIR, `${genreSlug}.md`);
    fs.writeFileSync(outputPath, parts.join('\n'), 'utf-8');
    console.log(`  -> ${path.relative(PROJECT_ROOT, outputPath)}`);
  }

  console.log('');
  console.log('===========================');
  console.log(`Compiled ${totalWorks} works across ${worksMap.size} genres`);
  console.log(`Total story word count: ${totalWordCount.toLocaleString()}`);
  console.log(`Output: ${path.relative(PROJECT_ROOT, OUTPUT_DIR)}/`);
}

main();
