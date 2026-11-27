# herdr (https://herdr.dev): tmux-style terminal multiplexer for coding
# agents — panes marked working/blocked/idle, detach without stopping
# work, agents drive it via CLI + socket API. Packaged in nixpkgs 26.05
# (0.9.5), but its Home Manager module (modules/programs/herdr.nix) only
# exists on HM master (added 2026-07-15, never backported to
# release-26.05, which this repo pins) — so the option is vendored here.
# Trimmed vendor: upstream's mutableSettings mode (and the
# lib.hm.generators.mkImpureConfigMerger/mkImpureConfigCleanup helpers
# it needs) is dropped because those helpers don't exist in HM 26.05;
# only the immutable xdg.configFile path is kept. Delete this file and
# use the upstream option once release-26.05 ships the module.
{den, ...}: {
  den.aspects.apps.herdr = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.herdr;

      tomlFormat = pkgs.formats.toml {};
      herdrBin =
        if cfg.package == null
        then "herdr"
        else lib.escapeShellArg (lib.getExe cfg.package);
      # Applies a changed config.toml to a running herdr server without
      # restart; the `|| true` covers the server-not-running case.
      reloadConfig = "${herdrBin} server reload-config || true";
    in {
      options.programs.herdr = {
        enable = lib.mkEnableOption "Herdr";

        # herdr is in the unstable pin (2786a2a7, 0.9.5) but absent from
        # the host's default pkgs tree (config.home-manager.users.*.pkgs
        # resolves "herdr cannot be found"; its source tree predates the
        # package). pkgs.unstable.<pkg> is the established convention for
        # this situation: btop, helix, zed-editor, fastfetch.
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = pkgs.unstable.herdr;
          defaultText = lib.literalExpression "pkgs.unstable.herdr";
          description = "The herdr package to use.";
        };

        settings = lib.mkOption {
          inherit (tomlFormat) type;
          default = {};
          description = ''
            Configuration written to `$XDG_CONFIG_HOME/herdr/config.toml`.
            See <https://herdr.dev/docs/configuration/> for the full list
            of options. Empty (default) leaves the file unmanaged, so
            herdr owns its own config.
          '';
        };
      };

      # The aspect bundles the module AND the enable switch (glow pattern:
      # including the aspect installs the app; opt out by not including it).
      config = {
        programs.herdr.enable = true;

        home.packages = lib.mkIf (cfg.package != null) [cfg.package];

        xdg.configFile."herdr/config.toml" = lib.mkIf (cfg.settings != {}) {
          source = tomlFormat.generate "herdr-settings.toml" cfg.settings;
          onChange = reloadConfig;
        };
      };
    };
  };
}
