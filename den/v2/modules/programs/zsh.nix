{
  flake.modules.nixos.zsh = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.unstable.zsh;
    users.defaultUserShell = pkgs.unstable.zsh;
  };
}
