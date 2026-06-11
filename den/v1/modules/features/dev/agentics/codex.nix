{ den, inputs, ... }: {
  den.aspects."codex" = {
    homeManager = {pkgs, ...}: {
      programs.codex = {
        enable = true;
        package = pkgs.unstable.codex;
      };
    };
  };
}
