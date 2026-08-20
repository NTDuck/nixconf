{
  den,
  inputs,
  ...
}: {
  den.aspects.compositors.mangowm = {terminal}: {
    includes = [
      # Required by plugins
      den.aspects.utilities.evtest
      den.aspects.utilities.screenshots.gpu-screen-recorder

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

        # DO NOT UNCOMMENT
        # DISPLAY = ":2";

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
    }: {
      imports = [
        inputs.mangowm.hmModules.mango
      ];

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

          ipc = "${config.programs.noctalia.package}/bin/noctalia msg";
        in {
          repeat_rate = 50;
          repeat_delay = 150;
          trackpad_natural_scrolling = 1;
          mouse_click_method = 2; # Clickfinger

          # syncobj_enable = 1;
          allow_lock_transparent = 1;
          drag_tile_to_tile = 1;
          drag_corner = 4;

          borderpx = 0;
          gappih = 6;
          gappiv = 6;
          gappoh = 6;
          gappov = 6;

          blur = 1;
          blur_layer = 0;
          blur_optimized = 1;
          blur_params_radius = 8;
          blur_params_num_passes = 2;
          blur_params_noise = 0.02;
          blur_params_brightness = 0.9;
          blur_params_contrast = 0.9;
          blur_params_saturation = 1.0;

          border_radius = 0;
          no_radius_when_single = 0;
          focused_opacity = config.stylix.opacity.applications;
          unfocused_opacity = 0.8 * config.stylix.opacity.applications;

          # https://mangowm.github.io/docs/visuals/animations
          animations = 1;
          layer_animations = 0;

          animation_type_open = "slide";
          animation_type_close = "slide";
          layer_animation_type_open = "slide";
          layer_animation_type_close = "slide";

          animation_fade_in = 1;
          animation_fade_out = 1;
          fadein_begin_opacity = 0.1;
          fadeout_begin_opacity = 0.9;
          animation_curve_opafadein = "0.0,0.55,0.45,1.0";
          animation_curve_opafadeout = "0.5,0.5,0.5,0.5";

          tag_animation_direction = 0;

          scroller_structs = 3; # 0.5 * `gap`
          scroller_default_proportion = 1.0;
          scroller_prefer_overspread = 0;
          scroller_focus_center = 1;
          scroller_prefer_center = 1;
          edge_scroller_focus_allow_speed = 0.0;
          scroller_ignore_proportion_single = 1;

          circle_layout = "scroller,dwindle";

          tagrule = lib.map (tag: "id:${tag},layout_name:scroller") tags;

          layerrule = [
            # https://docs.noctalia.dev/v4/getting-started/compositor-settings/hyprland/#blur
            # "layer_name:noctalia-background-.*$,noblur:1,noanim:1,noshadow:0"
            # "layer_name:noctalia-notifications-.*$,noblur:1,noanim:1,noshadow:1"
          ];

          bind =
            [
              "SUPER,a,toggleoverview"
              "SUPER,s,switch_layout"
              "SUPER,q,killclient"
              "SUPER,f,togglemaximizescreen"
              "SUPER+SHIFT,f,togglefullscreen"
              "SUPER+SHIFT,e,quit"
              "SUPER+SHIFT,r,reload_config"

              "SUPER,F11,view_insert,prev"
              "SUPER,F12,view_insert,next"

              "SUPER,d,spawn,${ipc} panel-toggle launcher"
              "SUPER+SHIFT,s,spawn,${ipc} screenshot-fullscreen"
              "SUPER+CTRL,l,spawn,${ipc} session lock"
              "SUPER,Return,spawn,${terminal pkgs}"
            ]
            ++ (lib.mapAttrsToList (key: dir: "SUPER,${key},focusdir,${dir}") dirs)
            ++ (lib.mapAttrsToList (key: dir: "SUPER+SHIFT,${key},exchange_client,${dir}") dirs)
            ++ (lib.map (tag: "SUPER,${tag},view,${tag}") tags)
            ++ (lib.map (tag: "SUPER+SHIFT,${tag},tagsilent,${tag}") tags)
            ++ (lib.map (tag: "SUPER+ALT,${tag},tag,${tag}") tags);

          bindl = [
            "NONE,XF86MonBrightnessDown,spawn,${ipc} brightness-down"
            "NONE,XF86MonBrightnessUp,spawn,${ipc} brightness-up"
            "NONE,XF86AudioMute,spawn,${ipc} volume-mute"
            "NONE,XF86AudioLowerVolume,spawn,${ipc} volume-down"
            "NONE,XF86AudioRaiseVolume,spawn,${ipc} volume-up"
          ];

          focus_on_activate = 0;
        };

        autostart_sh = ''
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
            WAYLAND_DISPLAY \
            DISPLAY \
            XDG_CURRENT_DESKTOP \
            XDG_SESSION_DESKTOP \
            XDG_SESSION_TYPE

          ${pkgs.systemd}/bin/systemctl --user import-environment \
            WAYLAND_DISPLAY \
            DISPLAY \
            XDG_CURRENT_DESKTOP \
            XDG_SESSION_DESKTOP \
            XDG_SESSION_TYPE

          ${config.programs.noctalia.package}/bin/noctalia &

          fcitx5 -d -r &
        '';

        systemd = {
          enable = true;
          xdgAutostart = true;
        };
      };
    };
  };
}
