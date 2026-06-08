{
  flake.modules.homeManager.vesktop = {
    pkgs,
    ...
  }: {
    programs.vesktop = {
      enable = true;
      package = pkgs.unstable.vesktop;
    };
  };
}
