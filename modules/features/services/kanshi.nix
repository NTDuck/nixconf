{den, ...}: {
  den.aspects.services.kanshi = {
    internalOutput,
    externalOutputs,
  }: {
    homeManager = {pkgs, ...}: let
      mirrorUnits = builtins.concatStringsSep " " (
        map (output: "wl-mirror@${output}.service") externalOutputs
      );

      stopMirrors = "${pkgs.systemd}/bin/systemctl --user stop ${mirrorUnits} || true";

      mirrorProfile = output: {
        profile = {
          name = "mirror-${output}";

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
            "${pkgs.systemd}/bin/systemctl --user restart wl-mirror@${output}.service"
          ];
        };
      };
    in {
      systemd.user.services."wl-mirror@" = {
        Unit = {
          Description = "Mirror ${internalOutput} onto %i";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
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

      services.kanshi = {
        enable = true;
        package = pkgs.unstable.kanshi;

        settings =
          (map mirrorProfile externalOutputs)
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
                  stopMirrors
                ];
              };
            }
          ];
      };
    };
  };
}
