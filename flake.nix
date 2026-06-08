{
  nixConfig = {
    extra-substituters = [
      "https://attic.xuyh0120.win/lantian" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "https://cache.garnix.io" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
    ];
    extra-trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
    ];
  };

  inputs = let
    version = "26.05";
  in {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-${version}";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-${version}";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # User Repository
    nur.url = "github:nix-community/NUR";

    stylix.url = "github:nix-community/stylix/release-${version}";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Kernel
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Sugars
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Formatter
    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Rust
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Agentics
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # llm-agents.inputs.bun2nix.url = "git+https://github.com/nix-community/bun2nix.git";
  };

  outputs = inputs: let
    modules = lib.pipe inputs.import-tree [
      # (module: module.matchNot ".*/common/.*")
      # (module: module.matchNot ".*/shared/.*")
      (module: module ./modules)
    ];
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} modules;
}

# 528491
