---
description: Incremental conventional commits (feat/fix); never batch or commit red trees
---

# Commit Rules
- Commit every logical change immediately after it verifies. Never batch unrelated changes into one commit.
- Conventional-commits prefixes: `feat(scope):` for new features or capabilities, `fix(scope):` for bug fixes. Use `chore:`, `refactor:`, `docs:`, `test:` when they fit. Scope is the area touched: `omp`, `legion`, `gaming`.
- Subject: imperative, present tense, ≤72 chars. Body explains why, not what — only when needed.
- Never commit a red tree. If eval, build, or switch fails, fix it before committing.
- Never mix a feat and a fix in one commit. Split them.

Examples:
- `fix(omp): malformed cfg`
- `fix(legion): wrong gpu power limit`
- `feat(omp): incremental commit rules`
- `feat(gaming): add lutris module`
