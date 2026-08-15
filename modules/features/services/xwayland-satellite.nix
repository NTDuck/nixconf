{den, ...}: {
  den.aspects.services.xwayland-satellite = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      # `xwayland-satellite` has native `systemd` support. Its upstream service
      # uses Type=notify and becomes ready after Xwayland initialization.
      systemd.user.services.xwayland-satellite = {
        Unit = {
          Description = "Xwayland Satellite";
          PartOf = [config.wayland.systemd.target];
          After = [config.wayland.systemd.target];
        };

        Service = {
          Type = "notify";
          NotifyAccess = "all";

          ExecStart = "${pkgs.unstable.xwayland-satellite}/bin/xwayland-satellite :2";

          Restart = "on-failure";
          RestartSec = 1;
        };

        Install = {
          WantedBy = [config.wayland.systemd.target];
        };
      };
    };
  };
}
