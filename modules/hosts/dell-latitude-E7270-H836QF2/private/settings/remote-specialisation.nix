# "remote" specialisation: DELL as a pure remote-desktop client.
#
# Boots into a tuigreet whose session menu offers moonlight-qt directly
# (cage kiosk — no compositor, no desktop furniture, maximum GPU/RAM for
# decoding legion's stream), with tailscale guaranteed up before greetd so
# the client can always reach legion off-LAN.
#
# Select with: sudo /run/current-system/bin/switch-to-configuration boot
#   + reboot → pick "remote" in the bootloader specialisation menu.
# The default (no specialisation) remains the full spectrwm desktop.
{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos = {
      pkgs,
      ...
    }: {
      specialisation.remote.configuration = {
        # --- tailscale autostart ---------------------------------------
        # The tailscale aspect enables tailscaled; bringing the mesh up is
        # normally interactive (`sudo tailscale up`, see aspect header). In
        # the remote spec the machine must rejoin unattended: the node is
        # already logged in (state persists in /var/lib/tailscale), so a
        # oneshot `tailscale up` before greetd is a no-op when up and
        # recovers after a `tailscale logout`/state wipe without needing an
        # auth key provisioned.
        systemd.services.tailscale-autoup = {
          description = "Rejoin the tailnet before the greeter (remote spec)";
          wantedBy = ["greetd.service"];
          before = ["greetd.service"];
          after = ["tailscaled.service"];
          wants = ["tailscaled.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            # No BROWSER pass-through needed: --accept-dns=false keeps it
            # non-interactive when logged in; when NOT logged in it prints
            # the auth URL to the journal and fails soft (greetd still
            # starts, moonlight just can't reach legion until someone runs
            # `tailscale up` interactively once).
            ExecStart = "${pkgs.tailscale}/bin/tailscale up --accept-dns=false";
            TimeoutStartSec = "30s";
            Restart = "on-failure";
            RestartSec = "5s";
          };
          unitConfig.ConditionPathExists = "/var/lib/tailscale/tailscaled.state";
        };

        # --- moonlight-qt as a greeter session -------------------------
        # tuigreet lists .desktop files from services.displayManager
        # .sessionPackages (share/wayland-sessions). A session runs as the
        # logged-in user via greetd, without the HM user PATH — so Exec
        # pins absolute store paths.
        #
        # cage -s: single-app kiosk Wayland compositor. moonlight-qt is a
        # Qt/SDL app; the labwc desktop is deliberately NOT started in this
        # spec, so the session needs a minimal compositor to host it.
        # --no-yuv444: the HD 520 decode constraint (see moonlight.nix).
        services.displayManager.sessionPackages = let
          # Same shape as the labwc aspect's overrideAttrs: a bare script
          # has no passthru.providedSessions, which the displayManager
          # sessionPackages type demands (assertion in
          # display-managers/default.nix lndir-loops over it too).
          moonlightSession = pkgs.runCommand "moonlight-qt-session" {} ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/moonlight.desktop <<'EOF'
            [Desktop Entry]
            Name=Moonlight (legion stream)
            Comment=Remote desktop client to legion (cage kiosk)
            Exec=${pkgs.cage}/bin/cage -s -- ${pkgs.moonlight-qt}/bin/moonlight --no-h265 --no-av1 --no-yuv444
            Type=Application
            DesktopNames=cage;moonlight
            EOF
          '';
        in [
          (moonlightSession.overrideAttrs (old: {
            passthru = (old.passthru or {}) // {providedSessions = ["moonlight"];};
          }))
        ];
      };
    };
  };
}
