# https://nix.catppuccin.com/options/main/nixos/catppuccin
{ inputs, ... }:

let
  accent = "mauve";
  flavor = "mocha";
in {
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    enable = true;

    inherit accent flavor;
    cursors.enable = true;

    cache = true;
    enableReleaseCheck = true;
  };
}
