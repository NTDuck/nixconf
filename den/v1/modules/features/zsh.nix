{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.zsh = {

  programs.zsh.enable = true;

  users.users.${username}.shell = pkgs.zsh;
  users.defaultUserShell = pkgs.zsh;

  };
}
