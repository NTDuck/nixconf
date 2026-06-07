{inputs, ...}: {
  flake.modules.homeManager.cava = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    home.packages = [
      pkgs.unstable.cava
    ];
  };
}
