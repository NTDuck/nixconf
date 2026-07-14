{den, ...}: {
  den.aspects.shells.zsh = {
    nixos = {...}: {
      programs.zsh.enable = true;
    };

    homeManager = {pkgs, ...}: {
      programs.zsh = {
        enable = true;
        package = pkgs.unstable.zsh;

        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      };
    };
  };
}
