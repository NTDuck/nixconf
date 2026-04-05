{pkgs, ...}: {
  programs.imv = {
    enable = true;
    package = pkgs.unstable.imv;
  };
}
