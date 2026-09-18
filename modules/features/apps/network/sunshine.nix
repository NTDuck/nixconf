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
# capability is scoped to the sunshine security wrapper only.
#
# Applications (2026-09-18, exhaustive 3-app set): (1) "Desktop (Native)" —
# plain capture of the running session, no prep; (2) "Desktop (dell-latitude-
# E7270-H836QF2)" — drops eDP-1 to its 60Hz mode for the DELL client (matches
# the client's 60Hz panel, halves compositor render load vs 165Hz; undo
# restores 165Hz). Mango REJECTS wlr-randr --custom-mode (live-tested
# 2026-09-18: "failed to apply configuration" for 1366x720 variants), so a
# literal 720p mode is impossible; instead sunshine's encode pipeline scales
# the capture to the client's requested resolution (1366x720) on its own.
# The removed "Low Res Desktop" (external HDMI mode switch) is superseded by
# entry (2) — it errored on open because the HDMI output is often absent/
# kanshi-driven. (3) "Steam (Big Picture)" detaches steam BP from the stream
# launch and closes it on detach.
#
# Settings reference: https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
{den, ...}: {
  den.aspects.apps.network.sunshine = {
    internalOutput,
  }: {
    nixos = {
      pkgs,
      config,
      lib,
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

          # Display: the internal panel streams by default; external outputs
          # are driven by the host's compositor/kanshi.
          output_name = internalOutput;

          # Encoder preference: nvenc requires cap_sys_admin which we don't
          # grant (see above); let sunshine auto-probe and fall back.
          # capture = "wlr";
        };

        applications = {
          env = {
            PATH = "$(PATH):$(HOME)/.local/bin";
          };

          apps =
            [
              # Plain desktop stream: no prep commands, sunshine captures the
              # current session whatever it is.
              {
                name = "Desktop (Native)";
                image-path = "desktop.png";
              }
            ]
            ++ [
              # DELL-tuned stream: the internal panel is the only output that
              # always exists, so park it at 60Hz (DELL's panel refresh) while
              # streamed. Resolution stays 2560x1600 on the host; sunshine
              # scales the encode to the client's requested 1366x720.
              # wlr-randr needs the compositor's WAYLAND_DISPLAY, which the
              # mango session imports into the systemd user environment that
              # sunshine's unit runs in.
              {
                name = "Desktop (dell-latitude-E7270-H836QF2)";
                image-path = "desktop.png";
                prep-cmd = [
                  {
                    do = "${pkgs.wlr-randr}/bin/wlr-randr --output ${internalOutput} --mode 2560x1600@60.007999Hz";
                    undo = "${pkgs.wlr-randr}/bin/wlr-randr --output ${internalOutput} --mode 2560x1600@165.018997Hz";
                  }
                ];
                exclude-global-prep-cmd = "false";
                auto-detach = "true";
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
