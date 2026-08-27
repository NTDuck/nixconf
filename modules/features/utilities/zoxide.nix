{den, ...}: {
  den.aspects.utilities.zoxide = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.zoxide = {
        enable = true;
        package = pkgs.unstable.zoxide;

        enableBashIntegration = lib.mkIf config.programs.bash.enable true;
        enableZshIntegration = lib.mkIf config.programs.zsh.enable true;
        enableFishIntegration = lib.mkIf config.programs.fish.enable true;
      };
    };
  };
}
