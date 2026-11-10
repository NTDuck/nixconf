{den, ...}: {
  den.aspects.dev.agentics.harnesses.codex = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.codex = {
        enable = true;
        # nixpkgs-unstable cargo-setup-hook exports AWS_LC_SYS_USE_SYSTEM=1,
        # ZSTD_SYS_USE_PKG_CONFIG=1, RUSTONIG_SYSTEM_LIBONIG=1 and codex links
        # -lsqlite3 — but the default-crate-overrides don't reach vendored
        # deps here. Add all four system libs explicitly.
        # pinned to nixpkgs-unstable rev f4a03c008967841f2a0b3cb7c436fc6fc31671f6
        package = pkgs.unstable.codex.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
          buildInputs = (old.buildInputs or []) ++ [ pkgs.unstable.aws-lc pkgs.zstd pkgs.unstable.oniguruma pkgs.sqlite ];
        });
      };

      home.shellAliases = {
        codex = "${config.programs.codex.package}/bin/codex --dangerously-bypass-approvals-and-sandbox";
      };
    };
  };
}
