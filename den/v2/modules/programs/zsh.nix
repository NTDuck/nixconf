{
  flake.modules.nixos.zsh = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;
    users.defaultUserShell = pkgs.zsh;
  };
}
