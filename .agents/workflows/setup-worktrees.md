---
description: Set up git worktrees for parallel content generation
---

# Setup Worktrees

Create 15 git worktrees for parallel content generation.

// turbo-all

## 1. Create worktrees

```bash
cd /Users/bedwards/writing/must-read.github.io
for i in $(seq 1 15); do
  git branch -f "worker/slot-$i" main 2>/dev/null
  git worktree add ".worktrees/worker-$i" "worker/slot-$i" 2>/dev/null || echo "Worktree worker-$i already exists"
done
```

## 2. Verify

```bash
git worktree list
```

You should see 15 worktrees plus the main checkout.

## 3. Confirm .gitignore

Ensure `.worktrees/` is in `.gitignore` (it should already be there).

```bash
grep -q '.worktrees/' .gitignore && echo "OK: .worktrees/ is gitignored" || echo "WARNING: add .worktrees/ to .gitignore"
```
