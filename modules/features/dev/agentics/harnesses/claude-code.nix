{den, ...}: {
  den.aspects.dev.agentics.harnesses.claude-code = {
    homeManager = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
