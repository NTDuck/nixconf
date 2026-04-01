{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # plugins = [
    #   {
    #     name = "powerlevel10k";
    #     src = pkgs.zsh-powerlevel10k;
    #     file = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    #   }
    # ];

    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      nix() {
        if [[ "$1" == "clean" ]]; then
          echo "`sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2`"
          sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
          echo "`nix-collect-garbage -d`"
          sudo nix-collect-garbage -d
        else
          command nix "$@"
        fi
      }
    '';
  };

  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
