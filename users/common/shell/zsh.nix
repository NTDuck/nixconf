{ pkg, username, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [ "git" "sudo" ];
    };

    initContent = ''
      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };

  users.users.${username}.shell = pkgs.zsh;
  users.defaultUserShell = pkgs.zsh;

  catppuccin.zsh-syntax-highlighting = {
    enable = true;
  };
}
