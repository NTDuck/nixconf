{inputs, ...}: {
  flake.modules.homeManager.vesktop = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.vesktop = {
      enable = true;
      package = pkgs.unstable.vesktop;
    };
  };
}
