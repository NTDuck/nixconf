{ pkgs, noctalia, noctalia-qs, username, ... }:

{
  home-manager.users.${username} = { config, ... }: {
    imports = [
      noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;

      settings = {
        bar = {
          density = "compact";
          position = "right";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                alwaysShowPercentage = false;
                id = "Battery";
                warningThreshold = 30;
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        # general = {
        #   avatarImage = "/home/drfoobar/.face";
        #   radiusRatio = 0.2;
        # };
        location = {
          # monthBeforeDay = true;
          name = "Marseille, France";
        };
      };

      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          catwalk = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };

      pluginSettings = {
        catwalk = {
          minimumThreshold = 25;
          hideBackground = true;
        };
      };
    };

    programs.niri = {
      settings = {
        spawn-at-startup = [
          {
            command = [
              "noctalia-shell"
            ];
          }
        ];

        binds = with config.lib.niri.actions; {
          "Mod+L".action = spawn "noctalia-shell" ["ipc" "call" "lockScreen" "lock"];
          "Mod+D".action = spawn "noctalia-shell" ["ipc" "call" "launcher" "toggle"];

          "XF86AudioLowerVolume".action = spawn "noctalia-shell" ["ipc" "call" "volume" "decrease"];
          "XF86AudioRaiseVolume".action = spawn "noctalia-shell" ["ipc" "call" "volume" "increase"];
          "XF86MonBrightnessDown".action = spawn "noctalia-shell" ["ipc" "call" "brightness" "decrease"];
          "XF86MonBrightnessUp". action = spawn "noctalia-shell" ["ipc" "call" "brightness" "increase"];
          "XF86AudioMute".action = spawn "noctalia-shell" ["ipc" "call" "volume" "muteOutput"];
        };
      };
    };
  };
}
