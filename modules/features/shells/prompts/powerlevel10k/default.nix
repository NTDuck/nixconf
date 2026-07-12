{
  den,
  inputs,
  ...
}: {
  den.aspects.shells.prompts.powerlevel10k = {
    homeManager = {pkgs, ...}: {
      programs.zsh = {
        initContent = ''
          source ${pkgs.unstable.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

          [[ ! -f "${inputs.self}/modules/features/shells/prompts/powerlevel10k/.p10k.zsh" ]] || source "${inputs.self}/modules/features/shells/prompts/powerlevel10k/.p10k.zsh"
        '';
      };
    };
  };
}
