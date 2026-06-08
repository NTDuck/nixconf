{
  flake.modules.homeManager.bluetuith = {pkgs, ...}: {
    programs.bluetuith = {
      enable = true;
      package = pkgs.unstable.bluetuith;
    };
  };
}
