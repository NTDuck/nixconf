{
  flake.modules.homeManager.codex = {pkgs, ...}: {
    programs.codex = {
      enable = true;
      package = pkgs.unstable.codex;
    };
  };
}
