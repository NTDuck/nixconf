{den, ...}: {
  den.aspects.dev.envs.mise = {
    homeManager = {
      pkgs,
      lib,
      config,
      ...
    }: {
      programs.mise = {
        enable = true;
        package = pkgs.unstable.mise;

        enableBashIntegration = lib.mkIf config.programs.bash.enable true;
        enableZshIntegration = lib.mkIf config.programs.zsh.enable true;
        enableFishIntegration = lib.mkIf config.programs.fish.enable true;
      };
    };
  };
}
