{
  den,
  inputs,
  ...
}: {
  den.aspects.compositors.mangowm = {
    includes = [
      den.aspects.services.cliphist # https://mangowm.github.io/docs/configuration/xdg-portals#clipboard-manager
      den.aspects.services.gnome-keyring # https://mangowm.github.io/docs/configuration/xdg-portals#gnome-keyring
      den.aspects.services.xdg # https://mangowm.github.io/docs/configuration/xdg-portals#screen-sharing
    ];

    nixos = {pkgs, ...}: {
      imports = [
        inputs.mangowm.nixosModules.mango
      ];

      programs.mango = {
        enable = true;
        package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

        addLoginEntry = true;
      };
    };

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      imports = [
        inputs.mangowm.homeModules.default
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

          ipc = "${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia-shell ipc call";
        in {
          monitorrule = "name:^eDP-1$,width:2560,height:1600,refresh:165.019,vrr:1";
          # TODO Others?

          repeat_rate = 50;
          repeat_delay = 150;
          trackpad_natural_scrolling = 1;
          click_method = 2; # Clickfinger

          syncobj_enable = 1;
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
          no_radius_when_single = 1;
          unfocused_opacity = 0.8;

          animation_type_open = "fade";
          animation_type_close = "fade";
          # TODO Change curve
          # https://www.cssportal.com/css-cubic-bezier-generator/

          circle_layout = "dwindle,scroller,overview";

          tagrule = tags |> lib.map (tag: "id:${tag},layout_name:scroller");

          # TODO ifguard
          layerrule = "layer_name:noctalia-background-.*$,noblur:1,noanim:1,noshadow:0";

          bind =
            [
              "SUPER,s,switch_layout"
              "SUPER,q,killclient"
              "SUPER,f,togglefakefullscreen"
              "SUPER+SHIFT,f,togglefullscreen"
              "SUPER+SHIFT,e,quit"

              "SUPER,Return,${pkgs.unstable.foot}/bin/footclient"
              "SUPER,d,${ipc} launcher toggle"
              "SUPER+CTRL,l,${ipc} lockScreen lock"
            ]
            ++ (dirs |> lib.mapAttrsToList (key: dir: "SUPER,${key},focusdir,${dir}"))
            ++ (dirs |> lib.mapAttrsToList (key: dir: "SUPER+SHIFT,${key},exchange_client,${dir}"))
            ++ (tags |> lib.map (tag: "SUPER,${tag},view,${tag}"))
            ++ (tags |> lib.map (tag: "SUPER+SHIFT,${tag},tagsilent,${tag}"))
            ++ (tags |> lib.map (tag: "SUPER+ALT,${tag},tag,${tag}"));

          bindl = [
            "NONE,XF86MonBrightnessDown,spawn,${ipc} brightness decrease"
            "NONE,XF86MonBrightnessUp,spawn,${ipc} brightness increase"
            "NONE,XF86AudioMute,spawn,${ipc} volume muteOutput"
            "NONE,XF86AudioLowerVolume,spawn,${ipc} volume decrease"
            "NONE,XF86AudioRaiseVolume,spawn,${ipc} volume increase"
          ];
        };

        autostart_sh = ''
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all &
          ${pkgs.systemd}/bin/systemctl --user import-environment &
          ${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia-shell &
          fcitx5 -d -r
        '';

        systemd = {
          enable = true;
          xdgAutostart = true;
        };
      };
    };
  };
}
