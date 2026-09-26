# Sunshine is the game-stream HOST: the Legion streams its display to Moonlight clients.
# Ports per https://docs.lizardbyte.dev/projects/sunshine/en/latest/about/guide.html
# (openFirewall covers TCP 47984/47989/47990/48010 + UDP 47998-48000/48010; the explicit
# firewall entries are belt-and-suspenders for setups that also need UDP 48010 control).
#
# settings/applications are DECLARED (2026-09-17): once `settings` or
# `applications` is non-empty the module renders a config file and Sunshine's
# web-UI config editing is disabled — that is the trade for a reproducible
# host. Credentials (username/password hash) stay in the mutable
# ~/.config/sunshine/sunshine_state.json, which the declarative config does
# not touch.
#
# Capture (reversed 2026-09-18 with user approval): capSysAdmin is now ON so
# sunshine can use DRM/KMS capture and probe NVENC on the 4060 — the previous
# wrapperless posture forced wlr-screencopy + software x264, which cost CPU
# and latency on every stream (log evidence: "Found H.264 encoder: libx264
# [software]", vaapi probe failed for lack of intel-media-driver). The
# capability is scoped to the sunshine security wrapper only. NOTE: the
# wrapper only lands after an os switch — check
# `ls /run/wrappers/bin/sunshine` and that the user unit's ExecStart points
# at the wrapper (journal 2026-09-18 showed libx264 because the running
# generation predated the capSysAdmin commit).
#
# Applications (2-app set since 2026-09-26; the "Desktop
# (dell-latitude-E7270-H836QF2)" SUNHEAD virtual-output app was removed at
# user request — moonlight just mirrors whatever the host session shows):
# (1) "Desktop (Native)" — plain capture of the running session, no prep;
# wlgrab falls back to the first real output (eDP-1) since no output_name
# is pinned. (2) "Steam (Big Picture)" detaches steam BP from the stream
# launch and closes it on detach.
#
# Settings reference: https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
{den, ...}: {
  den.aspects.remote-desktop.sunshine = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      services.sunshine = {
        enable = true;
        package = pkgs.unstable.sunshine;
        openFirewall = true;
        # Unlocks DRM/KMS capture + NVENC probing (see capture comment above).
        capSysAdmin = true;

        # keys/values land verbatim in sunshine.conf (pkgs.formats.keyValue).
        # Only the port option is schema'd by the module; everything else is
        # freeform per the upstream settings doc.
        settings = {
          # Base port; openFirewall derives TCP -5..+21 and UDP 9..21 from it
          # (47984-48010). Keep in sync with the explicit firewall entries
          # below for UDP 48010 control traffic.
          port = 47989;

          sunshine_name = config.networking.hostName;

          # Required for mDNS discovery by moonlight on mixed LANs; also lets
          # moonlight find the host over the tailscale mesh when avahi
          # publishes user services (module sets avahi up with mkDefault).
          origin_web_ui_allowed = "lan";

          # Stream defaults tuned for the DELL client over LAN/wifi: cap
          # bitrate high enough for 1080p60 but low enough for 2.4GHz hops.
          upnp = "disabled";
          min_log_level = 2;

          # No output_name pin: wlgrab probes the first real output (eDP-1),
          # which is what every app here streams.

          # Encoder/capture: cap_sys_admin is granted (see above), so
          # sunshine auto-probes NVENC on the 4060 and DRM/KMS capture; the
          # latency-critical knobs (nvenc_preset=1, sw_tune=zerolatency) are
          # already the sunshine defaults. Capture stays on auto
          # (nvfbc→wlr→kms): with cap_sys_admin KMS wins for real outputs,
          # while the virtual output is only reachable via the wlr backend —
          # probing happens per stream session, and a KMS lookup of the
          # named display fails over correctly. Forcing "wlr" would pin
          # every stream to zwlr_screencopy and lose KMS's zero-copy.
        };

        applications = {
          env = {
            PATH = "$(PATH):$(HOME)/.local/bin";
          };

          apps =
            [
              # Plain desktop stream: no prep commands, sunshine captures
              # the current session whatever it is (wlgrab -> eDP-1).
              {
                name = "Desktop (Native)";
                image-path = "desktop.png";
              }
            ]
            ++ [
              # Steam Big Picture: detach sunshine's launcher and open BP in the
              # user's existing steam (programs.steam is enabled on legion).
              {
                name = "Steam (Big Picture)";
                detached = ["setsid steam steam://open/bigpicture"];
                prep-cmd = [
                  {
                    do = "";
                    undo = "setsid steam steam://close/bigpicture";
                  }
                ];
                image-path = "steam.png";
              }
            ];
        };
      };

      networking.firewall.allowedTCPPorts = [47984 47989 47990 48010];
      networking.firewall.allowedUDPPorts = [47984 47989 47990 47998 47999 48000 48010];
    };

    homeManager = {pkgs, ...}: {
      home.packages = [
        pkgs.unstable.sunshine
      ];
    };
  };
}
