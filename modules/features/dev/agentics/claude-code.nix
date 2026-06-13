{
  den,
  inputs,
  ...
}: {
  den.aspects.claudeCode = {
    homeManager = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
      };
    };
  };
}
