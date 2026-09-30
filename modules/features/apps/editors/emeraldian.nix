{
  den,
  ...
}: {
  # Emeraldian: TUI for Obsidian vaults (three-pane live preview, backlinks,
  # graph). https://github.com/iamrohithrnair/emeraldian
  #
  # Absent from nixpkgs 26.05 AND unstable (checked 2026-09-30 via nix
  # search/eval), so the derivation is INLINED here (not a sibling
  # package.nix): import-tree sweeps every .nix under modules/ as a module,
  # and the module system would feed the package flake args — same shape as
  # apps/lemonhunt.
  #
  # Pinned to the v0.6.0 tag COMMIT (the tag object is annotated; ref sha
  # d9aa775... peels to a857a47...). rust-version 1.90 is satisfied by
  # 26.05's rustc 1.95.0, so no rust-overlay toolchain is needed. Cargo.lock
  # is pure crates.io (zero git deps) → cargoLock.lockFile straight from the
  # pinned src; build the whole workspace (the 3 lib crates are bin deps).
  den.aspects.apps.editors.emeraldian = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      src = pkgs.fetchFromGitHub {
        owner = "iamrohithrnair";
        repo = "emeraldian";
        rev = "a857a47273d2053e1552624296d78048732d78d6"; # v0.6.0
        hash = "sha256-qcUAGDoMZ60MrVtHcwTMoS/Y93+JR9OOPH7D0GGIHU4=";
      };
    in {
      home.packages = [
        (pkgs.rustPlatform.buildRustPackage {
          pname = "emeraldian";
          version = "0.6.0";

          inherit src;
          cargoLock.lockFile = src + "/Cargo.lock";

          meta = {
            description = "Terminal UI for your Obsidian vault: live-preview notes, backlinks, images, a force-directed graph and an assistant";
            homepage = "https://emeraldian-tui.github.io";
            license = lib.licenses.gpl3Plus;
            mainProgram = "emeraldian";
          };
        })
      ];
    };
  };
}
