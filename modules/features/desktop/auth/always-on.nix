# Always-on session for host DELL (2026-09-21 user request): the spectrwm
# login must never dim, blank, lock or suspend itself while idle. DELL is
# a streaming client (moonlight + VNC), so an idle screen-off mid-stream
# reads as a dead session, and the slock prompt on resume is friction.
#
# Updated 2026-09-22 for the X11 cut: swayidle is Wayland-only (requires
# ext_idle_notify_v1). xss-lock (the X11 equivalent) lives in
# desktop.auth.i3lock; this aspect only handles the logind-side belt-and-
# suspenders. The desktop.auth.i3lock include handles the PAM service
# and the xss-lock daemon; xss-lock respects logind's IdleAction=ignore
# and HandleLidSwitch=ignore via D-Bus, so no idle timeouts fire while
# these settings are in effect.
#
# Screen-off stays reachable by hand (spectrwm owns keybinds via
# xset); logind's hardware triggers are neutralized in the nixos block
# below.
{den, ...}: {
  den.aspects.desktop.auth.always-on = {
    homeManager = {pkgs, ...}: {
      # xss-lock is enabled by desktop.auth.i3lock; nothing to add here.
    };

    nixos = {lib, ...}: {
      # Belt-and-suspenders for paths xss-lock cannot see: logind owns
      # the hardware suspend triggers. HandleLidSwitch=ignore matters on
      # E7270 — the lid is often closed while streaming to the panel.
      # IdleAction=ignore prevents logind from triggering a sleep on
      # system-idle (xss-lock respects this via D-Bus).
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
        IdleAction = "ignore";
      };
      # No suspend targets at all: even a stray `systemctl suspend`
      # finds nothing to run. mkForce in case a future aspect re-enables
      # sleep.
      systemd.targets.sleep.enable = lib.mkForce false;
    };
  };
}
