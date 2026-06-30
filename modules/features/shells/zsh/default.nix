{
  den,
  inputs,
  ...
}: {
  den.aspects.shells.zsh = {
    nixos = {
      user,
      pkgs,
      ...
    }: {
      programs.zsh.enable = true;
      users.users.${user.name}.shell = pkgs.unstable.zsh;
    };

    homeManager = {pkgs, ...}: {
      programs.zsh = {
        enable = true;
        package = pkgs.unstable.zsh;

        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initContent = ''
          source ${pkgs.unstable.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

          [[ ! -f "${inputs.self}/modules/features/shells/zsh/.p10k.zsh" ]] || source "${inputs.self}/modules/features/shells/zsh/.p10k.zsh"
        '';
      };
    };
  };
}
