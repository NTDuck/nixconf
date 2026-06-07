{inputs, ...}: {
  flake.modules.nixos.alejandra = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    environment.systemPackages = [
      pkgs.alejandra
    ];
  };
}
