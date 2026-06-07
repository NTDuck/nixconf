{inputs, ...}: {
  flake.modules.homeManager.termusic = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    home.packages = [
      pkgs.unstable.termusic
    ];
  };
}
