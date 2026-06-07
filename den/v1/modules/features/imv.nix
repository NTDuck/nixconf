{inputs, ...}: {
  flake.modules.homeManager.imv = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.imv = {
      enable = true;
      package = pkgs.unstable.imv;
    };
  };
}
