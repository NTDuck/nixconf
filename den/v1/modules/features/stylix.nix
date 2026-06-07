{inputs, ...}: {
  flake.modules.nixos.stylix = {
    pkgs,
    config,
    ...
  }:
    import ../../../../targets/common/stylix.nix {
      inherit pkgs config inputs;
      self = inputs.self;
    };
}
