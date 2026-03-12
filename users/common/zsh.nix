{ ... }:

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

    initExtra = ''
      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };

  catppuccin.zsh-syntax-highlighting = {
    enable = true;
  };
}
