{
  flake.modules.homeManager.cava = {pkgs, ...}: {
    programs.cava = {
      enable = true;
      package = pkgs.unstable.cava;
    };
  };
}
