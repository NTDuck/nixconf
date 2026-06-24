{den, ...}: {
  den.aspects.dev.agentics.claude-code = {
    home-manager = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
