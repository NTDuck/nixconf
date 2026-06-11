{
  den.aspects.\"claude-code\" = {
    homeManager = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
