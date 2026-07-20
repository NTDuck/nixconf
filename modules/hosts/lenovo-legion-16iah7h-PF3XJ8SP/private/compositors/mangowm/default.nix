{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      environment.sessionVariables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };
    };

    provides.to-users.homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      systemd.user.services.xwayland-satellite = {
        Unit = {
          Description = "Xwayland Satellite";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };

        Service = {
          ExecStart = "${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :2";
          Restart = "on-failure";
          RestartSec = 1;
        };

        Install.WantedBy = ["graphical-session.target"];
      };

      # Mango has no clone/mirror directive in monitorrule. Placing HDMI at
      # the same layout origin as the panel makes both outputs render the same
      # compositor scene, unlike wl-mirror which creates a regular client
      # window and unlike wlr-randr which Mango has not handled reliably here.
      wayland.windowManager.mango = {
        settings = {
          monitorrule = lib.mkForce [
            "name:^eDP-1$,width:2560,height:1600,refresh:165.019,x:0,y:0,scale:1.5,vrr:1"
            "name:^HDMI(-A)?-[0-9]+$,x:0,y:0,scale:1,vrr:0"
          ];

          blur = lib.mkForce 1;
          blur_layer = lib.mkForce 1;
          blur_params_radius = lib.mkForce 8;
          blur_params_num_passes = lib.mkForce 2;
          border_radius = lib.mkForce 16;

          focused_opacity = lib.mkForce config.stylix.opacity.applications;
          unfocused_opacity = lib.mkForce 0.72;

          animations = lib.mkForce 1;
          layer_animations = lib.mkForce 1;
          animation_type_open = lib.mkForce "slide";
          animation_type_close = lib.mkForce "slide";
          layer_animation_type_open = lib.mkForce "fade";
          layer_animation_type_close = lib.mkForce "fade";

          bind = lib.mkAfter [
            "SUPER,Return,spawn,${pkgs.unstable.kitty}/bin/kitty"
          ];
        };

        autostart_sh = lib.mkBefore ''
          # Fractional scaling on the Legion panel uses Mango's recommended
          # Xwayland-satellite path to avoid blurry XWayland clients.
          # https://mangowm.github.io/docs/configuration/monitors#using-xwayland-satellite-to-prevent-blurry-xwayland-apps
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY
          ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY
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
        '';
      };
    };
  };
}
