{inputs, ...}: {
  flake.modules.homeManager.gh = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.gh = {
      enable = true;
      package = pkgs.unstable.gh;

      gitCredentialHelper.enable = true;
    };
  };
}
