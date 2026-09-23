# i3lock + xss-lock — session lock for the DELL spectrwm (X11) session,
# replacing the slock pairing (2026-09-23).
#
# WHY i3lock: same X11 role as slock but with a visible lock screen
# (background fill, indicator ring). Authenticates through its own PAM
# stack — `programs.i3lock.enable` on the NixOS side enables the system
# module AND defaults `security.pam.services.i3lock` on (verified:
# nixpkgs pam.nix line ~2612 `i3lock.enable = mkDefault
# config.programs.i3lock.enable`), so no hand-rolled PAM entry needed
# (slock needed one; i3lock does not).
#
# WHY xss-lock: spectrwm has no built-in idle daemon. xss-lock watches
# X screensaver events and runs the locker on idle; --transfer-sleep-lock
# hands the lock to i3lock on suspend/hibernate (logind path) too.
#
# Idle chain: HM's services.screen-locker (mynixos:
# https://mynixos.com/home-manager/options/services.screen-locker)
# owns the systemd user service. xautolock.disable = true switches it
# from the xautolock pairing to xss-lock + `xset s <timeout> <cycle>`
# ExecStartPre — one module owns the whole chain instead of our old
# hand-rolled service + idle.sh split.
{den, ...}: {
  den.aspects.desktop.auth.i3lock = {
    nixos = {
      # System i3lock module: puts i3lock in systemPackages and enables
      # the PAM service (security.pam.services.i3lock via mkDefault).
      programs.i3lock.enable = true;
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      services.screen-locker = {
        enable = true;
        # 10-minute idle timeout (matches the retired slock setup's
        # `xset s 600`); cycle 600s per screensaver spec.
        inactiveInterval = 10;
        # -n (--nofork): xss-lock waits for the locker process to exit
        # before resuming its event loop; plain i3lock forks a child and
        # exits the parent, which breaks the chain.
        # -c: fill color, hex WITHOUT '#' prefix (i3lock's -c format
        # matches stylix's base00-hex output directly).
        lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c ${config.lib.stylix.colors.base00-hex}";
        # xss-lock pairing (X screensaver events), not xautolock.
        # --transfer-sleep-lock: on suspend/hibernate xss-lock runs the
        # locker itself and hands over the sleep lock — the session
        # resumes locked. The idle timer is killed in the spectrwm
        # autostart (xset s off) so this daemon only fires on suspend
        # and manual lock, never on idle.
        xautolock.enable = false;
        xss-lock.extraOptions = ["--transfer-sleep-lock"];
      };
    };
  };
}
