{
  den,
  inputs,
  ...
}: {
  den.aspects.compositors.hyprland = {
    nixos = {pkgs, ...}: {
      programs.hyprland = {
        enable = true;
        package = pkgs.unstable.hyprland;

        withUWSM = true;
      };

      # https://wiki.hypr.land/Nix/Cachix/
      nix.settings = {
        extra-substituters = ["https://hyprland.cachix.org"];
        extra-trusted-substituters = ["https://hyprland.cachix.org"];
        extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };
    };

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      wayland.windowManager.hyprland = {
        enable = true;

        # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
        package = null;
        portalPackage = null;

        configType = "lua";

        settings = {
          "$mod" = "SUPER";

          # TODO Move to host-specific
          # TODO Change color
          # https://www.reddit.com/r/unixporn/s/fhb4wkagyy
          # https://wiki.hypr.land/Configuring/Basics/Variables/#syntax
          config = {
            # https://wiki.hypr.land/Configuring/Basics/Variables/#general
            general = {
              border_size = 4;
              gaps_in = 8;
              gaps_out = 0;
              float_gaps = 8;
              gaps_workspaces = 0;
              layout = "dwindle";
              no_focus_fallback = false;
              resize_on_border = true;
              extend_border_grab_area = 12;
              hover_icon_on_border = true;
              allow_tearing = false;
              resize_corner = 0;
              modal_parent_blocking = true;

              # https://wiki.hypr.land/Configuring/Basics/Variables/#snap
              snap = {
              };
            };

            # https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
            decoration = {
              rounding = 12;
              rounding_power = 2.0;
              active_opacity = 1.0;
              inactive_opacity = 0.6;
              fullscreen_opacity = 1.0;
              dim_modal = true;
              dim_inactive = true;
              dim_strength = 0.4;
              dim_special = 0.2;
              dim_around = 0.4;
              screen_shader = "${inputs.self}/assets/shaders/github:zer0-sh/retro4.frags";
              border_part_of_window = true;

              # https://wiki.hypr.land/Configuring/Basics/Variables/#blur
              blur = {
                enabled = true;
                size = 8;
                passes = 2;
                ignore_opacity = true;
                new_optimizations = true;
                xray = true;
                noise = 0.0117;
                contrast = 0.8916;
                brightness = 0.8172;
                vibrancy = 0.1696;
                vibrancy_darkness = 0.0;
                special = false;
                popups = true;
                popups_ignorealpha = 0.2;
                input_methods = true;
                input_methods_ignorealpha = 0.2;
              };

              # https://wiki.hypr.land/Configuring/Basics/Variables/#shadow
              shadow = {
                enabled = false;
              };

              # https://wiki.hypr.land/Configuring/Basics/Variables/#glow
              glow = {
                enabled = true;
                range = 4;
                render_power = 1;
              };

              # https://wiki.hypr.land/Configuring/Basics/Variables/#motion-blur
              motion_blur = {
                enabled = true;
                samples = 10;
              };
            };

            # https://wiki.hypr.land/Configuring/Basics/Variables/#animations
            animations = {
              enabled = true;
              workspace_wraparound = true;
            };

            # https://wiki.hypr.land/Configuring/Basics/Variables/#input
            input = {
              repeat_rate = 50;
              repeat_delay = 150;
              scroll_method = "2fg";
              follow_mouse = 2;
              focus_on_close = 2;

              # https://wiki.hypr.land/Configuring/Basics/Variables/#touchpad
              touchpad = {
                disable_while_typing = true;
                natural_scroll = true;
                tap_to_click = true;
                drag_lock = 0;
                tap_and_drag = true;
              };
            };

            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              vrr = 1;
              animate_manual_resizes = true;
              disable_autoreload = true;
              focus_on_activate = true;
              mouse_move_focuses_monitor = true;
            };

            # https://wiki.hypr.land/Configuring/Basics/Variables/#xwayland
            xwayland = {
              enabled = true;
              use_nearest_neighbor = false;
              force_zero_scaling = true;
              create_abstract_socket = false;
            };

            # https://wiki.hypr.land/Configuring/Basics/Variables/#opengl
            opengl.nvidia_anti_flicker = true;

            # https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
            dwindle = {
              force_split = 2;
            };
          };

          # https://wiki.hypr.land/Configuring/Basics/Monitors/
          monitor = {
            output = "eDP-1";
            mode = "2560x1600@165.019";
            position = "0x0";
            scale = 1;
          };

          # https://wiki.hypr.land/Configuring/Basics/Binds/
          # https://wiki.hypr.land/Configuring/Basics/Dispatchers/
          # https://github.com/end-4/dots-hyprland/blob/main/dots/.config/hypr/hyprland/keybinds.lua
          bind = let
            modifier = "SUPER";
            ipc = "qs -c noctalia-shell ipc call";

            mkCmd = key: cmd:
              mkBind key "hl.dsp.exec_cmd(\"${lib.strings.escape ["\"" "\\"] cmd}\")";

            mkBind = key: expr: {
              _args = [
                key
                (lib.generators.mkLuaInline expr)
              ];
            };

            mkFlaggedCmd = key: cmd: flags:
              mkFlaggedBind key "hl.dsp.exec_cmd(\"${lib.strings.escape ["\"" "\\"] cmd}\")" flags;

            mkFlaggedBind = key: expr: flags: {
              _args = [
                key
                (lib.generators.mkLuaInline expr)
                flags
              ];
            };

            forEachWorkspace = fn: builtins.genList (idx: fn (builtins.toString idx)) 10;
          in
            [
              (mkFlaggedBind "${modifier} + Q" "hl.dsp.window.close()" {long_press = true;})
              (mkBind "${modifier} + F" "hl.dsp.window.fullscreen({ mode = \"fullscreen\", action = \"toggle\" })")

              (mkBind "${modifier} + H" "hl.dsp.focus({direction = \"l\"})")
              (mkBind "${modifier} + J" "hl.dsp.focus({direction = \"d\"})")
              (mkBind "${modifier} + K" "hl.dsp.focus({direction = \"u\"})")
              (mkBind "${modifier} + L" "hl.dsp.focus({direction = \"r\"})")

              (mkBind "${modifier} + SHIFT + H" "hl.dsp.window.move({direction = \"l\"})")
              (mkBind "${modifier} + SHIFT + J" "hl.dsp.window.move({direction = \"d\"})")
              (mkBind "${modifier} + SHIFT + K" "hl.dsp.window.move({direction = \"u\"})")
              (mkBind "${modifier} + SHIFT + L" "hl.dsp.window.move({direction = \"r\"})")

              (mkCmd "${modifier} + RETURN" "${pkgs.unstable.foot}/bin/footclient")
              # (mkCmd "${modifier} + D" "${pkgs.unstable.tofi}/bin/tofi-drun --drun-launch=true")
              # (mkCmd "${modifier} + CTRL + L" "${pkgs.unstable.gtklock}/bin/gtklock")
              (mkCmd "${modifier} + D" "${ipc} launcher toggle")
              (mkCmd "${modifier} + CTRL + L" "${ipc} lockScreen lock")

              (mkFlaggedCmd "XF86MonBrightnessDown" "${ipc} brightness decrease" {
                locked = true;
                repeating = true;
              })
              (mkFlaggedCmd "XF86MonBrightnessUp" "${ipc} brightness increase" {
                locked = true;
                repeating = true;
              })
              (mkFlaggedCmd "XF86AudioMute" "${ipc} volume muteOutput" {locked = true;})
              (mkFlaggedCmd "XF86AudioLowerVolume" "${ipc} volume decrease" {
                locked = true;
                repeating = true;
              })
              (mkFlaggedCmd "XF86AudioRaiseVolume" "${ipc} volume increase" {
                locked = true;
                repeating = true;
              })
            ]
            ++ forEachWorkspace (idx: mkBind "${modifier} + ${idx}" "hl.dsp.focus({ workspace = ${idx} })")
            ++ forEachWorkspace (idx: mkBind "${modifier} + SHIFT + ${idx}" "hl.dsp.window.move({ workspace = ${idx}, follow = false })");

          # https://wiki.hypr.land/Configuring/Basics/Autostart/
          on = let
            mkOnEvent = event: cmds: {
              _args = [
                event
                (lib.generators.mkLuaInline ''
                  function()
                    ${builtins.concatStringsSep ";\n  " (map (lib.strings.escape ["\"" "\\"]) cmds)}
                  end
                '')
              ];
            };
          in [
            (mkOnEvent "hyprland.start" [
              "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
              "${pkgs.systemd}/bin/systemctl --user import-environment"
              "qs -c noctalia-shell"
              "fcitx5 -d -r"
            ])
          ];
        };

        # https://wiki.hypr.land/Useful-Utilities/Systemd-start/#uwsm
        systemd.enable = false;
      };
    };
  };
}
