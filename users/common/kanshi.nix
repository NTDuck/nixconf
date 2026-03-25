{ pkgs, ... }:

{
  services.kanshi.enable = true;

  home.packages = [
    pkgs.wlr-randr
    pkgs.wdisplays
  ];
}