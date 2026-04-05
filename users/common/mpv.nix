{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    package = pkgs.unstable.mpv;
  };
}
