{inputs, ...}: {
  flake.modules.homeManager.zalo = {pkgs, ...}:
    import ../../../../users/common/zalo.nix {inherit pkgs;};
}
