{den, ...}: {
  den.aspects.dev.envs.direnv = {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.direnv = {
        enable = true;
        package = pkgs.unstable.direnv;

        silent = true;

        enableBashIntegration = lib.mkIf config.programs.bash.enable true;
        enableZshIntegration = lib.mkIf config.programs.zsh.enable true;
        enableFishIntegration = lib.mkIf config.programs.fish.enable true;
      };
    };
  };
}
