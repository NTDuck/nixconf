# https://nix.catppuccin.com/options/main/nixos/catppuccin
{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    cursors.enable = true;

    accent = "mauve";
    flavor = "mocha";

    cache.enable = true;
    enableReleaseCheck = true;
  };
}
