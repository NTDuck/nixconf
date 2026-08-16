{
  den,
  inputs,
  ...
}: {
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
          cursor-style-blink = false;
          custom-shader = "${inputs.self}/assets/shaders/github:sahaj-b/cursor_tail.glsl";
          custom-shader-animation = "always";
          mouse-hide-while-typing = true;
          scrollbar = "never";
          window-padding-x = 14;
          window-padding-y = 10;
          # window-vsync = true;
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
