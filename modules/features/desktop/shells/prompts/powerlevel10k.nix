{
  den,
  inputs,
  ...
}: {
  den.aspects.desktop.shells.prompts.powerlevel10k = {
    homeManager = {pkgs, ...}: {
      programs.zsh = {
        initContent = ''
          source ${pkgs.unstable.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

          [[ ! -f "${inputs.self}/modules/features/desktop/shells/prompts/powerlevel10k/.p10k.zsh" ]] || source "${inputs.self}/modules/features/desktop/shells/prompts/powerlevel10k/.p10k.zsh"
        '';
      };
    };
  };
}
