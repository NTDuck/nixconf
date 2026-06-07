{inputs, ...}: {
  flake.modules.nixos.zsh = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.zsh;
    users.defaultUserShell = pkgs.zsh;
  };
}
