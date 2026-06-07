{inputs, ...}: {
  flake.modules.nixos.aalc = {pkgs, ...}:
    import ../../../../targets/common/aalc.nix {inherit pkgs;};
}
