# Always-on session for host DELL (2026-09-21 user request): the labwc
# login must never dim, blank, lock or suspend itself while idle. DELL is
# a streaming client (moonlight + VNC), so an idle screen-off mid-stream
# reads as a dead session, and the swaylock prompt on resume is friction.
#
# This aspect REPLACES the idle chain authored by desktop.auth.lockscreen
# (wlopm screen-off @10min, lock @20min, suspend @30min): it pins the
# same services.swayidle user unit with an EMPTY timeout list. Swayidle's
# timeouts/events default to [], so enablement alone means the daemon
# keeps ext_idle_notify_v1 alive without ever firing wlopm/swaylock/
# suspend. The desktop.auth.lockscreen include stays OUT of the DELL
# host: two HM modules writing services.swayidle on one aspect tree would
# collide, and list options CONCATENATE across aspects rather than
# last-wins — pull lockscreen back only if the idle chain is wanted.
#
# Screen-off stays reachable by hand (labwc owns keybinds); logind's
# hardware triggers are neutralized in the nixos block below.
{den, ...}: {
  den.aspects.desktop.auth.always-on = {
    homeManager = {pkgs, ...}: {
      services.swayidle = {
        enable = true;
        package = pkgs.unstable.swayidle;
        # systemdTargets (list) in 26.05 — replaces the single systemdTarget.
        systemdTargets = ["labwc-session.target"];
      };
    };

    nixos = {lib, ...}: {
      # Manual lock (W-C-l) still authenticates: the PAM service lived in
      # desktop.auth.lockscreen and must survive its removal.
      security.pam.services.swaylock = {};
      # Belt-and-suspenders for paths the idle daemon cannot see: logind
      # owns the hardware suspend triggers. HandleLidSwitch=ignore matters
      # on E7270 — the lid is often closed while streaming to the panel.
      # Key/lid handling moved under settings.Login (26.05 renamed the
      # flat options; e.g. suspendKey -> HandleSuspendKey).
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
      };
      # No suspend targets at all: even a stray `systemctl suspend` (the
      # retired lockscreen chain's 30-min timeout, a manual call) finds
      # nothing to run. mkForce in case a future aspect re-enables sleep.
      systemd.targets.sleep.enable = lib.mkForce false;
    };
  };
}
