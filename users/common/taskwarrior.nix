{pkgs, ...}: {
  programs.taskwarrior = {
    enable = true;
    package = pkgs.unstable.taskwarrior3;
  };

  home.packages = [
    pkgs.unstable.taskwarrior-tui
  ];
}
