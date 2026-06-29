{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur.url = "github:nix-community/NUR";

    stylix.url = "github:nix-community/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Kernel
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Sugars
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:denful/den";
    # flake-file.url = "github:vic/flake-file";

    # Secrets
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Compositor
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # VM
    nix-vert = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Formatter
    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Rust
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Agentics
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Noctalia
    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };

    # Telegram fork
    ayugram = {
      url = "github:ndfined-crp/ayugram-desktop/release";
      flake = true;
    };

    preservation.url = "github:nix-community/preservation";
  };

  # https://nix.dev/manual/nix/latest/command-ref/conf-file#available-settings
  # https://codeberg.org/Adda/nixos-config/src/commit/826b5ec6f5733e4b6bc0771dc9639e2e074358b5/flake.nix
  nixConfig = {
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;
  };
}
