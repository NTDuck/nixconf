# Session lock for the labwc (DELL) login: swaylock + PAM + idle hookups.
#
# WHY THE PAM DECLARATION IS NON-NEGOTIABLE: the stale labwc comment claimed
# "PAM service comes from programs.labwc" — false (verified against locked
# nixpkgs 2026-09-20: programs/labwc.nix declares only enable/package/
# portals/sessionPackages). The pam.services.swaylock entry ships from
# nixos/modules/programs/wayland/wayland-session.nix, imported only by DE
# display-manager session packages (gdm/sddm/lightdm), NOT by programs.labwc.
# DELL greets via tuigreet -> the labwc session wrapper, so W-C-l ran
# swaylock with no /etc/pam.d/swaylock -> auth failed instantly. Locking was
# dead-on-arrival; this aspect owns the PAM service now.
#
# Lock UX: stylix's swaylock target (auto-enabled on stateVersion >= 23.05)
# themes every color from kanagawa-dragon AND sets image/scaling to the
# shared wallpaper — the lock screen reads like the session.
#
# Idle chain (ext_idle_notify_v1, present in labwc's wlroots 0.19.3):
#   10 min   screen off (wlopm)     — resume re-powers outputs
#   20 min   lock, then suspend at 30 min via a second timeout
# Suspend resume hooks not needed: suspend only happens after lock.
{den, ...}: {
  den.aspects.desktop.auth.lockscreen = {
    nixos = {
      # swaylock authenticates through its own PAM stack; without this the
      # binary exits with "pam_authenticate failed" (see header comment).
      security.pam.services.swaylock = {};
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      # HM module installs the package and renders ~/.config/swaylock/config;
      # stylix.targets.swaylock (auto-enabled at this stateVersion) injects
      # the palette + wallpaper settings into the same set.
      programs.swaylock = {
        enable = true;
        package = pkgs.unstable.swaylock;
        # Timeouts longer than the indicator grace read as "hung"; lock
        # shows the clock so the idle screen-off is never mistaken for a
        # dead session.
        settings = {
          clock = true;
          timestr = "%H:%M";
          datestr = "%Y-%m-%d";
          indicator-idle-visible = true;
          show-failed-attempts = true;
        };
      };

      home.packages = [
        # wlopm: output power control for the idle chain (swaymsg-free; uses
        # wlr-output-power-management, present in labwc's wlroots).
        pkgs.unstable.wlopm
      ];

      services.swayidle = {
        enable = true;
        package = pkgs.unstable.swayidle;
        systemdTarget = "labwc-session.target";
        timeouts = [
          {
            timeout = 600; # 10 min
            command = "${pkgs.unstable.wlopm}/bin/wlopm --off '*'";
            resumeCommand = "${pkgs.unstable.wlopm}/bin/wlopm --on '*'";
          }
          {
            timeout = 1200; # 20 min
            command = "${config.programs.swaylock.package}/bin/swaylock -f";
          }
          {
            timeout = 1800; # 30 min
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
        # before-sleep: belt-and-suspenders if suspend is triggered by any
        # other path (logind lid close); -f waits for the lock to take.
        events = [
          {
            event = "before-sleep";
            command = "${config.programs.swaylock.package}/bin/swaylock -f";
          }
        ];
      };
    };
  };
}
