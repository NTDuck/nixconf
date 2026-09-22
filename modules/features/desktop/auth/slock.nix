# slock + xss-lock — session lock for the DELL spectrwm (X11) session,
# replacing swaylock + swayidle (2026-09-22).
#
# WHY slock: spectrwm is X11-only; swaylock is wlroots-only. slock is
# the suckless X11 screen locker (the canonical spectrwm pairing).
#
# WHY xss-lock: spectrwm has no built-in idle daemon. xss-lock watches
# X screensaver events and runs the locker on idle/suspend. The
# `--transfer-sleep-lock` flag hands the lock to slock on suspend/
# hibernate too (logind path), not just on X idle.
#
# xss-lock has NO HM module (verified — no services/xss-lock.nix in
# release-26.05), so we hand-roll a systemd user service. The service
# starts after the graphical session is up and runs xss-lock with the
# locker command from the spectrwm aspect's `programs.locker`.
#
# PAM: slock authenticates through its own PAM stack; without
# `security.pam.services.slock = {}` the binary exits with
# "pam_authenticate failed".
#
# Idle chain (X11): xset triggers the X screensaver after 10 min;
# xss-lock catches the screensaver activation and runs slock. No
# system suspend — always-on.nix disables sleep targets, and xset
# dpms only does display power management (not system suspend).
{den, ...}: {
  den.aspects.desktop.auth.slock = {
    nixos = {
      # slock authenticates through its own PAM stack; without this the
      # binary exits with "pam_authenticate failed".
      security.pam.services.slock = {};
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      home.packages = [
        pkgs.slock
        pkgs.xss-lock
      ];

      # Hand-rolled xss-lock systemd user service. HM has no
      # services.xss-lock module (verified against release-26.05).
      # The service starts after the graphical session target and
      # runs xss-lock with the locker command. The locker command
      # is read from the spectrwm aspect's programs.locker via the
      # spectrwm.conf file; we hardcode it here to avoid a circular
      # dependency between aspects.
      systemd.user.services.xss-lock = {
        Unit = {
          Description = "X screensaver/suspend lock daemon";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${pkgs.slock}/bin/slock";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };

      # X screensaver trigger: xset s 600 makes X fire the screensaver
      # after 10 minutes of idle. xss-lock catches the screensaver
      # activation and runs slock. This is sourced from the spectrwm
      # autostart (see spectrwm aspect).
      xdg.configFile."spectrwm/idle.sh".text = ''
        #!/bin/sh
        # Idle trigger for the DELL spectrwm session. Sourced from the
        # spectrwm autostart; see modules/features/desktop/compositors/
        # spectrwm/default.nix.
        xset s 600 5    # screensaver after 10 min, cycle every 5 min
      '';
    };
  };
}
