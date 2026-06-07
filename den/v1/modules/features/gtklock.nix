{inputs, ...}: {
  flake.modules.nixos.gtklock = {
    pkgs,
    config,
    lib,
    ...
  }:
    import ../../../../targets/common/gtklock.nix {
      inherit pkgs config lib;
      self = inputs.self;
    };
}
