{inputs, ...}: {
  flake.modules.nixos.greetd = {
    pkgs,
    config,
    ...
  }:
    import ../../../../targets/common/greetd.nix {inherit pkgs config;};
}
