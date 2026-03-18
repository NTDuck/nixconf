{
  config,
  pkgs,
  inputs,
  ...
}:

let
  accent = config.catppuccin.accent;
  flavor = config.catppuccin.flavor;
in
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;

    settings = {
      spawn-at-startup = [
        {
          argv = [
            "fcitx5"
            "-d"
            "-r"
          ];
        }
      ];

      binds = {
        "super+q".action = config.lib.niri.actions.close-window;
        "super+b".action = config.lib.niri.actions.spawn "${pkgs.firefox}/bin/firefox";
        "super+Return".action = config.lib.niri.actions.spawn "${pkgs.wezterm}/bin/wezterm";

        "super+f".action = config.lib.niri.actions.fullscreen-window;
        "super+t".action = config.lib.niri.actions.toggle-window-floating;

        # "control+shift+1".action = screenshot;
        # "control+shift+2".action = screenshot-window { write-to-disk = true; };

        "super+Left".action = config.lib.niri.actions.focus-column-left;
        "super+Right".action = config.lib.niri.actions.focus-column-right;
        "super+Down".action = config.lib.niri.actions.focus-workspace-down;
        "super+Up".action = config.lib.niri.actions.focus-workspace-up;

        "super+Shift+Left".action = config.lib.niri.actions.move-column-left;
        "super+Shift+Right".action = config.lib.niri.actions.move-column-right;
        "super+Shift+Down".action = config.lib.niri.actions.move-column-to-workspace-down;
        "super+Shift+Up".action = config.lib.niri.actions.move-column-to-workspace-up;
      };

      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = true;
      };

      prefer-no-csd = true;

      input = {
        focus-follows-mouse.enable = true;
        # repeat-delay = 200;  # ms
        # repeat-rate = 25;  # per second

        mouse = {
          enable = true;
          middle-emulation = true;
        };

        touchpad = {
          enable = true;

          accel-profile = "adaptive";
          click-method = "button-areas";
          disabled-on-external-mouse = true;
          dwt = true;
          dwtp = true;
          middle-emulation = true;
          natural-scroll = true;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
        };

        warp-mouse-to-focus.enable = false;
      };

      # outputs = {
      #   "DP-1" = {
      #     mode = {
      #       width = 2560;
      #       height = 1440;
      #       refresh = 359.97900;
      #     };
      #     scale = 1.0;
      #     position = { x = 0; y = 0; };
      #   };
      # };

      cursor = {
        hide-when-typing = true;
        size = 16;
      };

      layout = {
        # focus-ring = {
        #   enable = true;

        #   width = 2;
        #   active = "#${palette.${accent}.hex}";
        #   inactive = "#${palette.surface1.hex}";
        #   urgent = "#${palette.red.hex}";
        # };

        focus-ring = {
          enable = true;

          width = 2;
          active.color = "#cba6f7"; # "mocha" "mauve"
          inactive.color = "#45475a"; # "mocha" "surface1"
        };

        background-color = "#00000000"; # transparent

        gaps = 8;

        struts = {
          bottom = 8;
          left = 8;
          right = 8;
          top = 8;
        };
      };

      gestures = {
        hot-corners.enable = true;
      };

      # environment = {
      #   CLUTTER_BACKEND = "wayland";
      #   GDK_BACKEND = "wayland,x11";
      #   MOZ_ENABLE_WAYLAND = "1";
      #   NIXOS_OZONE_WL = "1";
      #   QT_QPA_PLATFORM = "wayland";
      #   QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      #   ELECTRON_OZONE_PLATFORM_HINT = "auto";

      #   XDG_SESSION_TYPE = "wayland";
      #   XDG_CURRENT_DESKTOP = "niri";
      #   DISPLAY = ":0";
      # };
    };
  };
}
