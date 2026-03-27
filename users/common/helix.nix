{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
    
    defaultEditor = true;
  };
}
