{inputs, ...}: {
  flake.modules.homeManager.pear-desktop = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    home.packages = [
      pkgs.unstable.pear-desktop
    ];
  };
}
