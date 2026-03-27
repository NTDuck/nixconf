# https://nix.catppuccin.com/options/main/home/catppuccin
{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;

    accent = "mauve";
    flavor = "mocha";

    enableReleaseCheck = true;
  };
}
