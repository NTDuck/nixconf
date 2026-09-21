---
description: Dendritic nix module files must start with `{den, ...}`, never bare `{...}`
---

# Dendritic Module Header Rule

- Every dendritic nix file that defines or extends `den.aspects.*` or `den.hosts.*` MUST start with the module lambda header `{den, ...}: {` (or the multiline form `{den, inputs, ...}: {`), never a bare `{ ... }` attrset, `_:` lambda, or `{inputs, ...}: {` without `den`.
- `den` stays in the header even when the body only sets `den.aspects.X = ...` attrset paths (which don't reference the binding) — it is uniform boilerplate, kept so future body code can use `den` and so `nixf-tidy --variable-lookup` residual "unused den" hits are ignored by convention.
- Aggregators (`default.nix` group files) follow the same rule.
- Scan: `nixf-tidy --variable-lookup` flags "attribute ... of argument is not used"; treat `den` hits as exempt, fix everything else.

Examples:
- Good: `{den, ...}: {\n  den.aspects.desktop.portals = {};\n}`
- Good multiline: `{den,\n inputs,\n ...}: { ... }`
- Bad: `{ den.aspects.x = {...}; }` (bare attrset, no lambda)
- Bad: `{inputs, ...}: { ... }` (missing `den` formal)
