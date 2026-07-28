{
  den,
  inputs,
  ...
}: {
  den.aspects.compositors.mangowm = {terminal}: {
    includes = [
      # Mango config and binds use Noctalia's IPC, and this session starts Noctalia
      # explicitly so its bars/lock shell exist in the compositor-only login.
      den.aspects.noctalia
      den.aspects.services.cliphist # https://mangowm.github.io/docs/configuration/xdg-portals#clipboard-manager
      # Mango is not a full desktop environment; start the input method inside
      # the compositor session so Vietnamese input works after login/reload.
      den.aspects.services.fcitx5
      den.aspects.services.gnome-keyring # https://mangowm.github.io/docs/configuration/xdg-portals#gnome-keyring
      den.aspects.services.xdg
    ];

    nixos = {pkgs, ...}: {
      imports = [
        inputs.mangowm.nixosModules.mango
      ];

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "mango";
        XDG_SESSION_DESKTOP = "mango";
        XDG_SESSION_TYPE = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
      };

      programs.mango = {
        enable = true;
        package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

        addLoginEntry = true;
      };
    };

    homeManager = {
      pkgs,
      config,
      lib,
      ...
    }: let
      internalOutput = "eDP-1";
      hdmiOutputs = ["HDMI-A-1" "HDMI-A-2" "HDMI-1" "HDMI-2"];
      hdmiMirrorUnits = lib.concatMapStringsSep " " (output: "hdmi-mirror@${output}.service") hdmiOutputs;
      stopHdmiMirrors = "${pkgs.systemd}/bin/systemctl --user stop ${hdmiMirrorUnits} || true";
      hdmiMirrorProfile = output: {
        profile = {
          name = "hdmi-mirror-${output}";

          outputs = [
            {
              criteria = internalOutput;
              status = "enable";
            }
            {
              criteria = output;
              status = "enable";
            }
          ];

          exec = [
            "${pkgs.systemd}/bin/systemctl --user restart hdmi-mirror@${output}.service"
          ];
        };
      };
    in {
      imports = [
        inputs.mangowm.hmModules.mango
      ];

      systemd.user.services = {
        xwayland-satellite = {
          Unit = {
            Description = "Xwayland Satellite";
            PartOf = [config.wayland.systemd.target];
            After = [config.wayland.systemd.target];
          };

          Service = {
            ExecStart = "${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :2";
            Restart = "on-failure";
            RestartSec = 1;
          };
        };

        "hdmi-mirror@" = {
          Unit = {
            Description = "Mirror ${internalOutput} onto %i";
            After = [config.wayland.systemd.target];
            PartOf = [config.wayland.systemd.target];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };

          Service = {
            Type = "simple";
            ExecStart = ''
              ${pkgs.unstable.wl-mirror}/bin/wl-mirror \
                --fullscreen-output %i \
                --scaling fit \
                ${internalOutput}
            '';
            Restart = "on-failure";
            RestartSec = "1s";
          };
        };
      };

      services.kanshi = {
        enable = true;
        package = pkgs.unstable.kanshi;

        settings =
          (map hdmiMirrorProfile hdmiOutputs)
          ++ [
            {
              profile = {
                name = "laptop";

                outputs = [
                  {
                    criteria = internalOutput;
                    status = "enable";
                  }
                ];

                exec = [
                  stopHdmiMirrors
                ];
              };
            }
          ];
      };

      wayland.windowManager.mango = {
        enable = true;
        package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

        settings = let
          tags = map builtins.toString (lib.range 1 9);
          dirs = {
            h = "left";
            j = "right";
            k = "up";
            l = "down";
          };

          # ipc = "${config.programs.noctalia.package}/bin/noctalia msg";
          # https://docs.noctalia.dev/v4/getting-started/keybinds/keybinds/#:~:text=Installation%2Dspecific%20commands
          ipc = "${config.programs.noctalia-shell.package}/bin/noctalia-shell ipc call";
        in {
          repeat_rate = 50;
          repeat_delay = 150;
          trackpad_natural_scrolling = 1;
          click_method = 2; # Clickfinger

          # syncobj_enable = 1;
          allow_lock_transparent = 1;
          drag_tile_to_tile = 1;
          drag_corner = 4;

          borderpx = 0;
          gappih = 8;
          gappiv = 8;
          gappoh = 8;
          gappov = 8;

          blur = 1;
          blur_layer = 1;
          blur_params_radius = 8;
          blur_params_num_passes = 2;
          border_radius = 16;

          focused_opacity = config.stylix.opacity.applications;
          unfocused_opacity = 0.8 * config.stylix.opacity.applications;

          # https://mangowm.github.io/docs/visuals/animations
          animations = 1;
          layer_animations = 1;

          animation_type_open = "fade";
          animation_type_close = "fade";
          layer_animation_type_open = "fade";
          layer_animation_type_close = "fade";

          animation_fade_in = 1;
          animation_fade_out = 1;
          fadein_begin_opacity = 0.1;
          fadeout_begin_opacity = 0.1;
          animation_curve_opafadein = "0,0.55,0.45,1.0";
          animation_curve_opafadeout = "0.55,0.5,1.0,0.45";

          tag_animation_direction = 0;

          circle_layout = "dwindle,scroller";

          tagrule = lib.map (tag: "id:${tag},layout_name:dwindle") tags;

          layerrule = [
            # https://docs.noctalia.dev/v4/getting-started/compositor-settings/hyprland/#blur
            "layer_name:noctalia-background-.*$,noblur:1,noanim:1,noshadow:0"
            "layer_name:noctalia-notifications-.*$,noblur:1,noanim:1,noshadow:1"
          ];

          smartgaps = 1;

          bind =
            [
              "SUPER,a,toggleoverview"
              "SUPER,s,switch_layout"
              "SUPER,q,killclient"
              "SUPER,f,togglemaximizescreen"
              # "SUPER,f,togglefakefullscreen"
              "SUPER+SHIFT,f,togglefullscreen"
              "SUPER+SHIFT,e,quit"

              # TODO Add Legion's Fn + Q
              # "SUPER,d,spawn,${ipc} panel-toggle launcher"
              # "SUPER+SHIFT,s,spawn,${ipc} screenshot-fullscreen"
              # "SUPER+CTRL,l,spawn,${ipc} session lock"
              "SUPER,d,spawn,${ipc} launcher toggle"
              "SUPER+CTRL,l,spawn,${ipc} lockScreen lock"
              "SUPER,Return,spawn,${terminal pkgs}"
            ]
            ++ (lib.mapAttrsToList (key: dir: "SUPER,${key},focusdir,${dir}") dirs)
            ++ (lib.mapAttrsToList (key: dir: "SUPER+SHIFT,${key},exchange_client,${dir}") dirs)
            ++ (lib.map (tag: "SUPER,${tag},view,${tag}") tags)
            ++ (lib.map (tag: "SUPER+SHIFT,${tag},tagsilent,${tag}") tags)
            ++ (lib.map (tag: "SUPER+ALT,${tag},tag,${tag}") tags);

          bindl = [
            # "NONE,XF86MonBrightnessDown,spawn,${ipc} brightness-down"
            # "NONE,XF86MonBrightnessUp,spawn,${ipc} brightness-up"
            # "NONE,XF86AudioMute,spawn,${ipc} volume-mute"
            # "NONE,XF86AudioLowerVolume,spawn,${ipc} volume-down"
            # "NONE,XF86AudioRaiseVolume,spawn,${ipc} volume-up"
            "NONE,XF86MonBrightnessDown,spawn,${ipc} brightness decrease"
            "NONE,XF86MonBrightnessUp,spawn,${ipc} brightness increase"
            "NONE,XF86AudioMute,spawn,${ipc} volume muteOutput"
            "NONE,XF86AudioLowerVolume,spawn,${ipc} volume decrease"
            "NONE,XF86AudioRaiseVolume,spawn,${ipc} volume increase"
          ];

          focus_on_activate = 0;
        };

        autostart_sh = ''
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
            WAYLAND_DISPLAY \
            XDG_CURRENT_DESKTOP \
            XDG_SESSION_DESKTOP \
            XDG_SESSION_TYPE

          ${pkgs.systemd}/bin/systemctl --user import-environment \
            WAYLAND_DISPLAY \
            XDG_CURRENT_DESKTOP \
            XDG_SESSION_DESKTOP \
            XDG_SESSION_TYPE

          ${pkgs.systemd}/bin/systemctl --user start xwayland-satellite.service

          for _ in $(${pkgs.coreutils}/bin/seq 1 100); do
            if ${pkgs.xset}/bin/xset -display :2 q >/dev/null 2>&1; then
              break
            fi
            ${pkgs.coreutils}/bin/sleep 0.05
          done
          export DISPLAY=:2
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY
          ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY

          ${config.programs.noctalia-shell.package}/bin/noctalia-shell

          fcitx5 -d -r &
        '';
        # ${config.programs.noctalia.package}/bin/noctalia &

        systemd = {
          enable = true;
          xdgAutostart = true;
        };
      };
    };
  };
}
