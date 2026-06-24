{den, ...}: {
  den.aspects.dev.agentics.codex = {
    home-manager = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.unstable.codex;
      };
    };
  };
}
