{den, ...}: {
  den.aspects.terminals.ghostty = {
    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      programs.ghostty = {
        enable = true;
        package = pkgs.unstable.ghostty;

        enableBashIntegration = lib.mkIf config.programs.bash.enable true;
        enableZshIntegration = lib.mkIf config.programs.zsh.enable true;
        enableFishIntegration = lib.mkIf config.programs.fish.enable true;

        settings = {
          cursor-style = "block";
          cursor-style-blink = "false";
          mouse-hide-while-typing = "true";
          srollbar = "never";
          window-padding-x = "10";
          window-padding-y = "14";
          window-vsync = "true";
          shell-integration-features = "no-cursor";
          quit-after-last-window-closed = false;
        };

        systemd = {
          enable = true;
        };
      };
    };
  };
}
