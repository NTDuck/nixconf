{den, ...}: {
  den.aspects.desktop.greeters.tuigreet = {command}: {
    nixos = {
      pkgs,
      config,
      lib,
      ...
    }: {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = ''
              ${pkgs.tuigreet}/bin/tuigreet \
              --cmd ${command config} --no-xsession-wrapper \
              --asterisks --asterisks-char '*' \
              --time --time-format '%Y-%m-%d %H:%M:%S' \
              --remember \
              --container-padding 2 \
            '';
            user = "greeter";
          };
        };
      };

      # The eGPU adopter (firmware/egpu/default.nix) may rescan the tunneled GPU at
      # boot; mango's EGL init must not race that rescan — a half-
      # initialized card0 made tuigreet fall back to llvmpipe ("Fail to
      # start EGL, render software", seen 2026-09-12).
      # CONDITIONAL (2026-09-21): the adopter now exists ONLY inside the
      # legion homelab specialisation — a hard after/wants on the unit name
      # would fail the default generation's boot transaction ("wants" is
      # soft, but After= on a missing unit still records a failed
      # dependency). Unit-existence check keeps the ordering where it
      # exists and no-ops where it doesn't.
      systemd.services.greetd = {
        after = lib.optional (config.systemd.units ? "egpu-adopt.service") "egpu-adopt.service";
        wants = lib.optional (config.systemd.units ? "egpu-adopt.service") "egpu-adopt.service";
      };

      services.xserver.enable = false;
      console.earlySetup = true;
    };
  };
}
