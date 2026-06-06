# Migration Blueprint

Migrating a conventional Nix flake to a dendritic config requires restructuring around features. 

## Step 1: Scaffold the Root
- Keep `flake.nix` minimal: only inputs and a call to `flake-parts.lib.mkFlake`.
- Use `import-tree` to generate the root of your flake.
- Create a `modules/` (or `den/modules/`) directory, which `import-tree` will recursively evaluate.

## Step 2: Establish Module Classes
- Integrate `flake.modules.nixos`, `flake.modules.homeManager`, and `flake.modules.darwin`. This allows you to namespace different aspect definitions within the same feature file.

## Step 3: Feature Extraction (The Migration Core)
- Identify paired files in your current structure (e.g., `targets/common/foo.nix` and `users/common/foo.nix`).
- Create a new feature file `den/modules/features/foo.nix`.
- Map the system config to `flake.modules.nixos.foo`.
- Map the user config to `flake.modules.homeManager.foo`.
- For variables shared between them, use a `let ... in` block at the top of the file, avoiding the need for `specialArgs`.

## Step 4: Host Definitions
- In your existing hosts (e.g., `targets/host-a`), translate the old explicit module imports into a list of feature imports.
- Make hosts lightweight by only including the list of capabilities they enable.

## Step 5: Iterative Rollout
- Do not migrate everything at once. `flake-parts` allows you to incrementally migrate features one by one, verifying your host config builds after each step. 
- You can run `nixos-shell` to test modules in an ephemeral VM locally before fully committing the changes to your actual system.
