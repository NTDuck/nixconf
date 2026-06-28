{den, ...}: {
  den.aspects.dev.agentics.pi = {
    homeManager = {pkgs, ...}: {
      programs.pi-coding-agent = {
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

    # nixos = {pkgs, ...}: {
    #   environment.systemPackages = [pkgs.unstable.pi-coding-agent];
    # };
  };
}
