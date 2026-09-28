# "remote" specialisation: DELL as a pure remote-desktop client.
#
# Boots STRAIGHT into the moonlight kiosk (cage fullscreen — no greeter,
# no compositor, no desktop furniture, maximum GPU/RAM for decoding
# legion's stream), with tailscale guaranteed up before greetd so the
# client can always reach legion off-LAN. greetd's restart defaults off
# when initial_session is set (nixpkgs greetd.nix), so an app exit lands
# on the plain default_session greeter (tuigreet listing all sessions,
# including the full x11 desktop) instead of re-entering moonlight in a
# loop.
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
        # --- greetd: autologin into the kiosk ---------------------------
        # The tuigreet aspect (inherited into this specialisation) sets
        # default_session = tuigreet --cmd <x11-session>. Adding
        # initial_session makes greetd start the KIOSK as ayin directly at
        # boot (autologin) and flips the service's restart default off, so
        # when the app exits greetd falls back to default_session — the
        # greeter — instead of looping the kiosk.
        services.greetd.settings.initial_session = {
          # Absolute store paths throughout: greetd hands sessions a
          # minimal env, and cage is NOT in systemPackages on this spec
          # (verified 2026-09-28 — only the moonlight aspect's package
          # lands in sw/bin), so a PATH-based `exec cage` would die with
          # "command not found". Same shape as the .desktop Exec below
          # (cage takes APPLICATION + args after --).
          command = pkgs.writeShellScript "moonlight-kiosk" ''
            exec ${pkgs.cage}/bin/cage -s -- /run/current-system/sw/bin/moonlight --video-codec H.264 --no-yuv444 --display-mode fullscreen
          '';
          user = "ayin";
        };

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

        # --- moonlight-qt as a greeter-listed session -------------------
        # With initial_session above this entry is NOT the boot path — it
        # is what the fallback greeter's session menu (tuigreet lists
        # services.displayManager.sessionPackages) offers for manually
        # re-entering the kiosk after an app exit, without a reboot.
        # A session runs as the logged-in user via greetd, without the HM
        # user PATH — so Exec pins absolute paths.
        #
        # cage -s: single-app kiosk Wayland compositor. moonlight-qt is a
        # Qt/SDL app; the labwc desktop is deliberately NOT started in this
        # spec, so the session needs a minimal compositor to host it.
        # Flags (2026-09-28, verified against moonlight 6.1.0 --help):
        # --no-h265/--no-av1 do not exist ("Unknown options: no-h265");
        # codec selection is --video-codec. /run/current-system/sw/bin/
        # moonlight is the HD 520-patched package from the moonlight
        # aspect (forces H.264 + YUV444 off at the settings level; the CLI
        # flags mirror that defense-in-depth).
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
            Exec=${pkgs.cage}/bin/cage -s -- /run/current-system/sw/bin/moonlight --video-codec H.264 --no-yuv444 --display-mode fullscreen
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
