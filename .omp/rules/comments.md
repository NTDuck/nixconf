---
description: Non-obvious code must carry a comment recording the historical decision behind it, so it stays traceable
---

# Historical Decision Comments
- Every non-obvious block — workaround, pin, tuning constant, tool choice, ordering constraint — gets a comment stating WHY it is written this way: the historical decision, not a restatement of what the code does.
- A reader six months out MUST be able to reconstruct the decision from the comment alone. Link the issue, commit, or upstream source that motivated it when one exists.
- When a decision is reversed or a pin is bumped, update or delete the stale comment in the same change. Stale comments are worse than none.
- Do not comment obvious code. Decision comments exist for choices a competent reader would otherwise question.

Examples:
- `# Pinned to 2026.8.250 so the store hash stays reproducible; bump both strings together.`
- `# oci-containers cannot build from source (no registry image upstream), hence a custom podman service.`
- `# 2026-09-14: 4d keep-since retained every gen under heavy iteration; tightened to 1d — see journal evidence.`
