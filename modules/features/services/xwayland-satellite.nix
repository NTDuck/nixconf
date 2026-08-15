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

          StandardOutput = "journal";

          Restart = "on-failure";
          RestartSec = 1;
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };

      # Make DISPLAY available to subsequently activated user services.
      systemd.user.services.xwayland-satellite.Service.ExecStartPost = "${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY";
    };
  };
}
