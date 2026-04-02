{ pkgs, ... }:

{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.unstable.taskwarrior;
  };

  home.packages = [
    pkgs.unstable.taskwarrior-tui
  ];
}
