{den, ...}: {
  den.aspects.dev.agentics.pi = {
    homeManager = {
      programs.pi-coding-agent = {pkgs, ...}: {
        enable = true;
        package = pkgs.unstable.pi-coding-agent;

        keybindings = {
          "tui.editor.cursorDown" = [
            "down"
            "ctrl+n"
          ];
          "tui.editor.cursorUp" = [
            "up"
            "ctrl+p"
          ];
        };

        settings = {
          packages = [
            "git:github.com/tmustier/pi-extensions"
            "git:github.com/DietrichGebert/ponytail"
          ];
        };
      };
    };
  };
}
