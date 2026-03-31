{ pkgs, config, ... }:

let
  # Grab the hex colors (with the '#' prefix) from your active Stylix theme
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.fastfetch = {
    enable = true;
    package = pkgs.unstable.fastfetch;

    settings = {
      logo = {
        source = "arch";
        padding = {
          top = 2;
          right = 6;
        };
      };
      display = {
        separator = "  ";
        constants = [
          "─────────────────" # Line separator
        ];
      };
      modules = [
        {
          type = "title";
          color = {
            user = c.base0B; # Green
            at = c.base08;   # Red
            host = c.base0D; # Blue
          };
        }
        {
          type = "custom";
          format = "{$1}";
        }
        {
          type = "os";
          key = "OS   ";
          keyColor = c.base0D;
        }
        {
          type = "kernel";
          key = "Kern ";
          keyColor = c.base0D;
        }
        {
          type = "packages";
          key = "Pkgs ";
          keyColor = c.base0D;
        }
        {
          type = "uptime";
          key = "Up   ";
          keyColor = c.base0D;
        }
        {
          type = "custom";
          format = "{$1}";
        }
        {
          type = "wm";
          key = "WM   ";
          keyColor = c.base0B;
        }
        {
          type = "shell";
          key = "Sh   ";
          keyColor = c.base0B;
        }
        {
          type = "terminal";
          key = "Term ";
          keyColor = c.base0B;
        }
        {
          type = "terminalfont";
          key = "Font ";
          keyColor = c.base0B;
        }
        {
          type = "custom";
          format = "{$1}";
        }
        {
          type = "cpu";
          key = "CPU  ";
          keyColor = c.base0A; # Yellow
        }
        {
          type = "gpu";
          key = "GPU  ";
          keyColor = c.base0A;
        }
        {
          type = "memory";
          key = "RAM  ";
          keyColor = c.base0A;
        }
        {
          type = "custom";
          format = "{$1}";
        }
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };

  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
