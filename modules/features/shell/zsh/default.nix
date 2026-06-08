{
  flake.modules.nixos.zsh = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
  in {
    programs.zsh.enable = true;

    users.users.${username}.shell = pkgs.unstable.zsh;
    users.defaultUserShell = pkgs.unstable.zsh;
  };

  flake.modules.homeManager.zsh = {pkgs, ...}: {
    programs.zsh = {
      enable = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '';
    };

    home.file.".p10k.zsh".source = ./.p10k.zsh;
  };
}
