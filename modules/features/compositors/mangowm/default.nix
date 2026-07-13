{
  den,
  inputs,
  ...
}: {
  den.aspects.compositors.mangowm = {
    includes = [
      den.aspects.services.cliphist # https://mangowm.github.io/docs/configuration/xdg-portals#clipboard-manager
      den.aspects.services.gnome-keyring # https://mangowm.github.io/docs/configuration/xdg-portals#gnome-keyring
    ];

    nixos = {pkgs, ...}: {
      imports = [
        inputs.mangowm.nixosModules.mango
      ];

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "mango";
        XDG_SESSION_DESKTOP = "mango";
        XDG_SESSION_TYPE = "wayland";
        MOZ_ENABLE_WAYLAND = "1";
        DISPLAY = ":2";
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
          tags = lib.range 1 9 |> map builtins.toString;
          dirs = {
            h = "left";
            j = "right";
            k = "up";
            l = "down";
          };

          # TODO Assuming noctalia, fix later
          ipc = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia msg";
        in {
          repeat_rate = 50;
          repeat_delay = 150;
          trackpad_natural_scrolling = 1;
          click_method = 2; # Clickfinger

          # syncobj_enable = 1;
          allow_lock_transparent = 1;
          drag_tile_to_tile = 1;
          drag_corner = 4;

          borderpx = 1;
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

          animation_type_open = "slide";
          animation_type_close = "slide";
          layer_animation_type_open = "fade";
          layer_animation_type_close = "fade";
          # TODO Change curve
          # https://www.cssportal.com/css-cubic-bezier-generator/

          circle_layout = "dwindle,scroller";

          tagrule = tags |> lib.map (tag: "id:${tag},layout_name:dwindle");

          layerrule =
            []
            ++ lib.optionalAttrs (config.programs.noctalia.enable or false) [
              "layer_name:noctalia-background-.*$,noblur:1,noanim:1,noshadow:0"
            ];

          bind =
            [
              "SUPER,a,toggleoverview"
              "SUPER,s,switch_layout"
              # "SUPER,z,spawn,sudo /run/current-system/specialisation/light-mode/activate && ${ipc} theme-mode-set light"
              # "SUPER,x,spawn,sudo /nix/var/nix/profiles/system/bin/switch-to-configuration test && ${ipc} theme-mode-set dark"
              "SUPER,q,killclient"
              "SUPER,f,togglemaximizescreen"
              # "SUPER,f,togglefakefullscreen"
              "SUPER+SHIFT,f,togglefullscreen"
              "SUPER+SHIFT,e,quit"

              "SUPER,Return,spawn,${pkgs.unstable.kitty}/bin/kitty"
              # "SUPER,Return,spawn,${pkgs.unstable.foot}/bin/footclient"
              "SUPER,d,spawn,${ipc} panel-toggle launcher"
              "SUPER+CTRL,l,spawn,${ipc} session lock"
            ]
            ++ (dirs |> lib.mapAttrsToList (key: dir: "SUPER,${key},focusdir,${dir}"))
            ++ (dirs |> lib.mapAttrsToList (key: dir: "SUPER+SHIFT,${key},exchange_client,${dir}"))
            ++ (tags |> lib.map (tag: "SUPER,${tag},view,${tag}"))
            ++ (tags |> lib.map (tag: "SUPER+SHIFT,${tag},tagsilent,${tag}"))
            ++ (tags |> lib.map (tag: "SUPER+ALT,${tag},tag,${tag}"));

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
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
          ${pkgs.systemd}/bin/systemctl --user import-environment

          # https://mangowm.github.io/docs/configuration/monitors#using-xwayland-satellite-to-prevent-blurry-xwayland-apps
          ${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :2 &

          ${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia &

          fcitx5 -d -r &

          ${pkgs.xdg-desktop-portal-wlr}/bin/xdg-desktop-portal-wlr &
        '';

        systemd = {
          enable = true;
          xdgAutostart = true;
        };
      };
    };
  };
}
