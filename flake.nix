{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree.matchNot ".*/private/.*" ./modules);

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # User Repository
    nur.url = "github:nix-community/NUR";

    stylix.url = "github:nix-community/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Kernel
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Sugars
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";

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
  };

  # https://nix.dev/manual/nix/latest/command-ref/conf-file#available-settings
  # https://codeberg.org/Adda/nixos-config/src/commit/826b5ec6f5733e4b6bc0771dc9639e2e074358b5/flake.nix
  nixConfig = {
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;

    # TODO Verify
    extra-substituters = [
      "https://attic.xuyh0120.win/lantian" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "https://cache.garnix.io" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
      "https://cache.lix.systems"
      "https://chaotic-nyx.cachix.org"
    ];
    extra-trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" # `xddxdd`'s CachyOS Kernel binary cache, Hydra CI
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" # `xddxdd`'s CachyOS Kernel binary cache, Garnix CI
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };
}
