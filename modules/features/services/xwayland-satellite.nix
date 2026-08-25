{den, ...}: {
  den.aspects.services.xwayland-satellite = {
    homeManager = {pkgs, ...}: {
      systemd.user.services.xwayland-satellite = {
        Unit = {
          Description = "Xwayland outside your Wayland";
          BindsTo = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          Requisite = ["graphical-session.target"];
        };

        Service = {
          Type = "notify";
          NotifyAccess = "all";

          Environment = [
            "DISPLAY=:2"
          ];

          ExecStart = "${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :2";

          # Set DPI for XWayland clients so they render at the correct resolution
          # for a 1.5× scaled display (96 × 1.5 = 144 DPI).
          # Without this, XWayland apps assume 96 DPI (scale 1.0) and appear
          # blurry/low-resolution when the compositor upscales them.
          ExecStartPost = [
            "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY"
            # Systemd does not use a shell for ExecStartPost entries, so wrap
            # in bash. Use echo | xrdb (not a here-string) to avoid nested
            # quoting issues between Nix strings and bash.
            "${pkgs.bash}/bin/bash -c 'echo Xft.dpi:144 | ${pkgs.xrdb}/bin/xrdb -merge -display :2'"
          ];

          StandardOutput = "journal";

          Restart = "on-failure";
          RestartSec = 1;
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    };
  };
}
