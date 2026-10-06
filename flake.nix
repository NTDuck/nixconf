{
  outputs = inputs:
    builtins.removeAttrs
    (inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules))
    ["denful"];

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

    # Lix
    # https://wiki.lix.systems/books/contributing/page/running-lix-main
    # lix = {
    #   url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
    #   flake = false;
    # };

    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.lix.follows = "lix";
    # };

    # Sugars
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:denful/den";
    # flake-file.url = "github:vic/flake-file";

    # Secrets
    # Pinned: 0.15.0 @ 3daa710 has a rekey regression (agenix.sh DEFAULT_DECRYPT
    # accumulates a -o per edited file; rage rejects repeated --output) that fails
    # the package installCheck and runtime `agenix -r`. Drop when upstream fixes.
    agenix.url = "github:ryantm/agenix/b027ee29d959fda4b60b57566d64c98a202e0feb";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    # Compositor
    # Pinned: 99e6ba3 (2026-10-05, "Standardize all configuration formats") renames
    # config keywords (tagrule→tag_rule, exec-once→exec_once) but its HM module
    # (nix/hm-modules.nix) still emits `exec-once=`, so any config fails its
    # validator → mango-config.conf.drv → home-manager-files.drv → switch fails.
    # Unpin + migrate settings keys when upstream fixes the module.
    mangowm = {
      url = "github:mangowm/mango/74dcc153122e6707d2c027e88a2e4d88264a2d09";
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

    # Inference: ninfer-3090 (SM86 Qwen3.8-27B engine) — pinned to the
    # validated v0.6.1-rtx3090 tag commit (no branch tracking; master is
    # untested). See modules/hosts/.../agentics/ninfer.nix.
    ninfer.url = "github:Don-Chad/ninfer-3090/47d71067afa20571c34b1e8f1d187aa2b48ff6f8";

    # llano V12 Ultra cooling pad control (Holtek USB-HID 374a:b101,
    # Myth.Cool protocol) — source-only input, pinned to the v0.1.4 tag
    # commit (protocol live-verified upstream; master is untested). Packaged
    # inline in modules/hosts/.../private/firmware/llano.nix. NOT in
    # nixpkgs as of 2026-10.
    llano-v12ultra-ctrl = {
      url = "github:Quahuay/llano-v12ultra-ctrl/2f2bce7ae20f452a3c4cdcb89db01c53e198023f";
      flake = false;
    };

    # Noctalia
    noctalia = {
      # https://docs.noctalia.dev/noctalia/getting-started/nixos/?section=binary-cache#binary-cache:~:text=tracking%20main%20directly%20may%20pull%20in%20a%20commit%20that%20hasn%E2%80%99t%20been%20cached%20yet%20by%20CI
      url = "github:noctalia-dev/noctalia/cachix";
      # url = "github:noctalia-dev/noctalia/v4.7.7";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Browser
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };

    # Telegram fork
    # ayugram = {
    #   url = "github:ndfined-crp/ayugram-desktop/release";
    #   flake = true;
    # };
  };

  # Keep evaluator policy in the flake so `nh os switch` and CI see the same settings
  # https://nix.dev/manual/nix/latest/command-ref/conf-file#available-settings
  # https://codeberg.org/Adda/nixos-config/src/commit/826b5ec6f5733e4b6bc0771dc9639e2e074358b5/flake.nix
  nixConfig = {
    accept-flake-config = true;
    allow-import-from-derivation = true;
    auto-optimise-store = true;
  };
}
