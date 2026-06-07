{inputs, ...}: {
  flake.modules.homeManager.cliphist = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    services.cliphist = {
      enable = true;
      package = pkgs.unstable.cliphist;

      allowImages = true;
    };
  };
}
