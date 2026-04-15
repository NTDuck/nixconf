{pkgs, ...}: {
  home.packages = [
    pkgs.unstable.kuzu
  ];
}
