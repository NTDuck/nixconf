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
            "${pkgs.xorg.xrdb}/bin/xrdb -merge -display :2 <<<'Xft.dpi: 144'"
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
