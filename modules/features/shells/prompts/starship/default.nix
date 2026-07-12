{den, ...}: {
  den.aspects.shells.prompts.starship = {
    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: {
      programs.starship = {
        enable = true;
        package = pkgs.unstable.starship;

        enableBashInteration = lib.mkIf config.programs.bash.enable true;
        enableZshIntegration = lib.mkIf config.programs.zsh.enable true;
        enableFishIntegration = lib.mkIf config.programs.fish.enable true;
      };
    };
  };
}
