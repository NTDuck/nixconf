# btop — terminal system monitor. Added to both DELL and legion
# (2026-09-22 user request).
#
# HM module:
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/btop.nix
{den, ...}: {
  den.aspects.apps.btop = {
    homeManager = {pkgs, ...}: {
      programs.btop = {
        enable = true;
        package = pkgs.unstable.btop;
      };
    };
  };
}
