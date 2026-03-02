# Git & Deployment Discipline

## Golden Rule: Local and GitHub Stay Synced

**ALWAYS** keep the local repository and GitHub in sync. GitHub Actions builds the site — that is the **source of truth**. Never leave un-pushed files sitting locally.

## Before Making Changes

```bash
# Always rebase from origin before starting work
git fetch origin
git rebase origin/main
```

## After Making Changes

```bash
# Stage, commit, pull --rebase, push — every time
git add -A
git commit -m "<type>(<scope>): <description>"
git pull --rebase origin main
git push origin main
```

## Non-Negotiable Rules

1. **Do not regress.** Never lose content or functionality. Before pushing, verify the build passes locally with `npx astro build`.
2. **Do not leave un-pushed files.** Every commit gets pushed immediately.
3. **Rebase, don't merge.** Use `git pull --rebase` to keep history clean.
4. **GitHub Actions is the source of truth.** The deployed site is what matters. If the GitHub Actions build fails after push, fix it immediately.
5. **Check before force-pushing.** Never force-push without understanding what you're overwriting.
