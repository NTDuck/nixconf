{den, ...}: {
  den.aspects.zsh = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      programs.zsh.enable = true;
      users.defaultUserShell = pkgs.unstable.zsh;
    };

    homeManager = {pkgs, ...}: {
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
  };
}
