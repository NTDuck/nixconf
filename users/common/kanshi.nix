{pkgs, ...}: {
  services.kanshi = {
    enable = true;
    package = pkgs.unstable.kanshi;
  };

  home.packages = [
    pkgs.unstable.wlr-randr
    pkgs.unstable.wdisplays
  ];
}
