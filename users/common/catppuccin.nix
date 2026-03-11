# https://nix.catppuccin.com/options/main/home/catppuccin
{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    enableReleaseCheck = true;

    accent = "mauve";
    flavor = "mocha";
  };
}
