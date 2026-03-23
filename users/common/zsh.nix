{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # initContent = ''
    #   bindkey -M emacs '^[e' expand-cmd-path
    #   bindkey -M viins '^[e' expand-cmd-path
    #   bindkey -M vicmd '^[e' expand-cmd-path
    #   sudo-command-line() {
    #       [[ -z $BUFFER ]] && zle up-history
    #       if [[ $BUFFER == sudo\ * ]]; then
    #           LBUFFER="''${LBUFFER#sudo }"
    #       elif [[ $BUFFER == $EDITOR\ * ]]; then
    #           LBUFFER="sudoedit ''${LBUFFER#$EDITOR }"
    #       elif [[ $BUFFER == sudoedit\ * ]]; then
    #           LBUFFER="$EDITOR ''${LBUFFER#sudoedit }"
    #       else
    #           LBUFFER="sudo $LBUFFER"
    #       fi
    #   }
    #   zle -N sudo-command-line
    #   # Binds 'ESC ESC' to add sudo
    #   bindkey "\e\e" sudo-command-line
    # '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}