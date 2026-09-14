---
description: Incremental conventional commits (full spec); never batch or commit red trees
---

# Commit Rules
- Commit every logical change immediately after it verifies. Never batch unrelated changes into one commit.
- Follow Conventional Commits 1.0.0: `<type>(<scope>): <subject>`, optional body, optional footer.
- Types: `feat` (new capability), `fix` (bug fix), `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`, `revert`, `style`.
- Scope is the area touched: `omp`, `legion`, `gaming`, `nix`.
- Breaking changes: `!` after the type/scope (`feat(gaming)!: ...`) and/or a `BREAKING CHANGE:` footer.
- Subject: imperative, present tense, ≤72 chars, no trailing period. Body explains why, not what — only when needed.
- Never commit a red tree. If eval, build, or switch fails, fix it before committing.
- Never mix a feat and a fix in one commit. Split them.

Examples:
- `fix(omp): malformed cfg`
- `fix(legion): wrong gpu power limit`
- `feat(omp): incremental commit rules`
- `feat(gaming): add lutris module`
- `feat(gaming)!: replace wine with wine-wayland`
