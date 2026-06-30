{den, ...}: {
  den.aspects.dev.agentics.codex = {
    homeManager = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.unstable.codex;
      };
    };
  };
}
