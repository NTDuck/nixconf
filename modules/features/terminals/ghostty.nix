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
          mouse-hide-while-typing = true;

          scrollbar = "never";
          window-padding-x = 14;
          window-padding-y = 10;

          # `systemd` integration
          quit-after-last-window-closed = false;

          # Kitty-like trailing cursor
          custom-shader = "${inputs.self}/assets/shaders/github:sahaj-b/cursor_tail.glsl";
          custom-shader-animation = "always";
          shell-integration-features = "no-cursor";

          # Prevent inheriting working directory
          window-inherit-working-directory = false;
          tab-inherit-working-directory = false;
          split-inherit-working-directory = false;
        };

        systemd = {
          enable = true;
        };
      };
    };
  };
}
