# tmux — terminal multiplexer. Added to both DELL and legion
# (2026-09-28 user request): dell attaches to a running legion terminal
# session over SSH, so both hosts need the same tmux.
#
# HM module:
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/tmux.nix
{den, ...}: {
  den.aspects.apps.tmux = {
    homeManager = {pkgs, ...}: {
      programs.tmux = {
        enable = true;
        package = pkgs.unstable.tmux;
      };
    };
  };
}
