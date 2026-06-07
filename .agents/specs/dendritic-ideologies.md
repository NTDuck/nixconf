# Dendritic Nix OS Ideologies & Conventions

## Core Ideology
- **Configuration Pattern, not a Framework:** Dendritic is an approach to structuring Nix configurations.
- **Feature-centric over Host-centric:** Configurations are organized by *capability* (e.g., `scrolling-desktop.nix`), not by the underlying host or the specific package name.
- **Universal Semantic Meaning:** Every `.nix` file within the architecture is a `flake-parts` module.
- **Thin Root:** The `flake.nix` file remains minimal, deferring logic and configurations to the `modules/` tree.

## Architecture & Conventions
- **Aspects Configuration:** Modules use `flake.modules.<class>.<aspect>` to define configuration blocks for different contexts. 
  - Classes include: `nixos`, `darwin`, `homeManager`, and `generic`.
- **Auto-loading:** Files are automatically discovered and imported. Instead of manual imports, the `import-tree` utility evaluates all `.nix` files under `modules/` (ignoring `common/`, `shared/`, or prefixed with `_`).
- **Feature Closures:** A single file (feature) encapsulates all configurations—NixOS settings, Darwin settings, Home Manager dotfiles, and `perSystem` derivations—for that particular capability.
- **Directory Structure:** Organize files by what the features *do* (e.g., `programs/`, `services/`, `hosts/`). Anti-patterns include directories named `nixos/` or `home-manager/` which fracture features.
- **Activation via Import:** Features are activated on a host by simply importing the relevant aspect in the host's module list. Avoid explicit `enable = true` boilerplate for internal modules unless necessary.
- **Shared Data & "This" Paradigm:** Use `let` bindings inside a file for local sharing. For sharing constants or data globally across features, use a `this` module (a `generic` module) to define repo-wide options rather than relying on `specialArgs`.

## Host Composition Example
```nix
# modules/hosts/my-laptop/default.nix
{ inputs, ... }: {
  imports = [
    inputs.self.modules.nixos.ssh
    inputs.self.modules.nixos.wayland-desktop
    # other capabilities
  ];
}
```
