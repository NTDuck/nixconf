{inputs, ...}: {
  flake.modules.homeManager.mpv = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.mpv = {
      enable = true;
      package = pkgs.unstable.mpv;
    };
  };
}
