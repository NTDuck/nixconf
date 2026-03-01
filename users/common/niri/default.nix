{ config, pkgs, niri, ... }:

{
  imports = [
    niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;

      layout = {
        background-color = "#00000000";

        focus-ring = {
          enable = true;
          width = 3;
          active = {
            color = "#A8AEFF";
          };
          inactive = {
            color = "#505050";
          };
        };

        gaps = 6;

        struts = {
          left = 20;
          right = 20;
          top = 20;
          bottom = 20;
        };
      };

      input = {
        touchpad = {
          click-method = "button-areas";
          dwt = true;
          dwtp = true;
          natural-scroll = true;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
          middle-emulation = true;
          accel-profile = "adaptive";
        };
        focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = false;
      };

      outputs = {
        "DP-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 359.97900;
          };
          scale = 1.0;
          position = { x = 0; y = 0; };
        };
      };

      cursor = {
        size = 20;
        theme = "Adwaita";
      };

      environment = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        DISPLAY = ":0";
      };
    };
  };

  programs.niri.settings.binds = with config.lib.niri.actions; {
    # # Quickshell Keybinds Start
    # "super+Control+Return".action = spawn ["qs" "ipc" "call" "globalIPC" "toggleLauncher"];
    # # Quickshell Keybinds End

    "xf86audioraisevolume".action = spawn "${pkgs.pulseaudio}/bin/pactl" [ "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
    "xf86audiolowervolume".action = spawn "${pkgs.pulseaudio}/bin/pactl" [ "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];

    # "control+super+xf86audioraisevolume".action = spawn "brightness" "up";
    # "control+super+xf86audiolowervolume".action = spawn "brightness" "down";

    "super+q".action = close-window;
    "super+b".action = spawn "${pkgs.firefox}/bin/firefox";
    "super+Return".action = spawn "${pkgs.ghostty}/bin/ghostty";
    "super+d".action = spawn "${pkgs.tofi}/bin/tofi";
    #"super+Control+Return".action = spawn apps.appLauncher;
    # "super+E".action = spawn apps.fileManager;

    "super+f".action = fullscreen-window;
    "super+t".action = toggle-window-floating;

    # "control+shift+1".action = screenshot;
    # "control+shift+2".action = screenshot-window { write-to-disk = true; };

    "super+Left".action = focus-column-left;
    "super+Right".action = focus-column-right;
    "super+Down".action = focus-workspace-down;
    "super+Up".action = focus-workspace-up;

    "super+Shift+Left".action = move-column-left;
    "super+Shift+Right".action = move-column-right;
    "super+Shift+Down".action = move-column-to-workspace-down;
    "super+Shift+Up".action = move-column-to-workspace-up;
  };
}