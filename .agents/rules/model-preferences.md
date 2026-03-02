# Model Preferences

## Text & Orchestration (Main Session)
Use **Claude Opus 4.6** for:
- Interactive orchestration and planning (this Antigravity session)
- Decision-making, quality review, assembly

## Independent Worker Processes (Gemini CLI)
Use **Gemini CLI** (`gemini -p`) for independent, fresh-context worker sessions:
- Story writing, editing, reviewing — each in its own isolated context
- Model: **`gemini-3-flash-preview`** (confirmed working)
- Invocation: `gemini -m gemini-3-flash-preview -p '<prompt>' --output-format json`

### Model Version Policy
- **NEVER use Gemini 2.5 or anything before version 3.** Only Gemini 3+ models.
- **Preferred**: `gemini-3.1-pro-preview` or latest Pro model — but Pro is **not reliably available** (capacity issues on Google's side as of March 2026).
- **Current workhorse**: `gemini-3-flash-preview` — fast, available, good quality.
- **Stay alert** for new model versions (Pro, Flash, or new tiers). When a new stable Pro model becomes available, switch workers to it.

## Images & Visual Analysis
Use **Gemini models** (latest available) for:
- Image reading and analysis
- Image creation and generation
- Visual content processing
