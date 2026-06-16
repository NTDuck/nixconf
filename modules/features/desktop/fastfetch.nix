{
  den,
  inputs,
  ...
}: {
  den.aspects.fastfetch = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.fastfetch
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.fastfetch = {
        enable = true;
        package = pkgs.unstable.fastfetch;

        settings = {
          logo = {
            source = "nixos";
            padding = {
              right = 1;
            };
          };
          display = {
            size = {
              maxPrefix = "GB";
            };
          };
          modules = [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "display"
            "de"
            "wm"
            "wmtheme"
            "theme"
            "icons"
            "font"
            "cursor"
            "terminal"
            "terminalfont"
            "cpu"
            "gpu"
            "memory"
            "disk"
            "battery"
            "poweradapter"
            "locale"
            "break"
            "colors"
          ];
        };
      };

      home.shellAliases = {
        ff = "fastfetch";
      };
    };
  };
}
