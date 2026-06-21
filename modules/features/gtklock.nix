{den, ...}: {
  den.aspects.gtklock = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.adwaita-icon-theme
      ];

      programs.gtklock = {
        enable = true;

        config = {
          main = {
            time-format = "%H:%M:%S";
            date-format = "";
          };
        };

        style = ''
          window {
            background-image: linear-gradient(rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8)), url("''${self}/assets/wallpapers/girls-last-tour-library.jpg");
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
          }
          * {
            font-family: "''${fonts.monospace.name}";
            color: ''${colors.base05};
            border-radius: 0px;
            box-shadow: none;
            text-shadow: none;
          }
          #clock-label {
            font-family: "''${fonts.monospace.name}";
            font-size: ''${clockFontSize}px;
            font-weight: 400;
            margin-bottom: 20px;
            color: ''${colors.base0B};
          }
          #date-label,
          #input-label,
          #unlock-button {
            display: none;
          }
          entry {
            background-color: rgba(0, 0, 0, 0.5);
            border: 1px solid ''${colors.base0B};
            color: ''${colors.base05};
            font-size: ''${entryFontSize}px;
            font-family: "''${fonts.monospace.name}";
            padding: 10px 20px;
            caret-color: ''${colors.base05};
            min-width: 300px;
            letter-spacing: 4px;
            border-radius: 4px;
            -GtkPasswordEntry-show-peek-icon: true;
          }
          entry:focus {
            border: 2px solid ''${colors.base0B};
            background-color: rgba(0, 0, 0, 0.8);
          }
          entry text {
            color: ''${colors.base05};
          }
          entry text:blank {
            color: transparent;
          }
          #warning-label {
            font-family: "''${fonts.monospace.name}";
            color: ''${colors.base08};
            font-size: ''${warningFontSize}px;
            margin-top: 20px;
          }
          entry image {
            color: ''${colors.base05};
            background: transparent;
            min-width: 24px;
            min-height: 24px;
            font-family: "''${fonts.emoji.name}";
          }
        '';
      };
    };
  };
}
