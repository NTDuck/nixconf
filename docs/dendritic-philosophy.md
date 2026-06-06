# Dendritic Configuration Pattern

The Dendritic pattern is a design philosophy for structuring Nix flake configurations using `flake-parts` and `import-tree`. Rather than organizing files by the system they configure (NixOS, Darwin, Home Manager) or their specific tool functionality, a dendritic config is structured around **features**—the cross-cutting usability concerns.

## Core Principles

1. **Every file is a `flake-parts` module**: Instead of trying to juggle different import styles for NixOS modules, Home Manager modules, or regular packages, everything in a dendritic config is an imported `flake-parts` module.
2. **Features as the Unit of Composition**: Files are named after the *experience* they configure, not the underlying tool. A file like `sway.nix` or `scrolling-desktop.nix` is a single feature that configures both the system and the user environment.
3. **Multi-Context Aspects**: A single file (`sway.nix`) can define modules for `nixos`, `homeManager`, and `darwin` simultaneously using the `flake.modules.<class>.<aspect>` pattern. The host simply imports the feature, and the relevant configs apply cleanly to the respective environments.
4. **Automatic Import**: Using `import-tree`, all files in the `modules/` directory are auto-discovered and imported. This eliminates the need to manually wire imports and reduces `flake.nix` to a simple set of inputs and a `mkFlake` call.
5. **Colocation of Context**: Instead of keeping system configs (e.g., `targets/common/sway.nix`) and user configs (`users/common/sway.nix`) separate, all related configuration logic, variables, and overrides live in the exact same place.

This approach gives maximum freedom to organize your config logically while leveraging Nix's powerful module system across different environments without boilerplate.
