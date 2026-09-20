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
# Applications (2026-09-18, 3-app set): (1) "Desktop (Native)" — plain capture
# of the running session, no prep; (2) "Desktop (dell-latitude-E7270-H836QF2)"
# — creates a mango HEADLESS virtual output (mmsg dispatch
# create_virtual_output,SUNHEAD) pinned to the DELL's native 1366x768@60 via
# a monitorrule in the host's mango config, and points the stream at it.
# Sunshine's Linux `output_name` is a GLOBAL setting (display_device is
# Windows-only), but wlgrab matches captures by xdg_output name and falls
# back to the first real output when the name is absent (wlgrab.cpp) — so
# with output_name = "SUNHEAD": the DELL app creates the output and streams
# it 1:1 (zero host-side scaling, native 768p60), while Native streams keep
# capturing eDP-1. undo destroys all virtual outputs. wlr-randr is only a
# safety re-assert: the monitorrule alone gives the headless output its
# custom mode at creation (mango monitor.c applies custom modes to headless
# outputs). (3) "Steam (Big Picture)" detaches steam BP from the stream
# launch and closes it on detach.
#
# Settings reference: https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
{den, ...}: {
  den.aspects.remote-desktop.sunshine = {
    nixos = {
      pkgs,
      config,
      ...
    }: let
      # Prep-cmds run through boost::process on the raw string (no shell):
      # compound shell syntax is unsafe there, so the create+retry sequence
      # lives in this script and the app's `do` stays one absolute path.
      sunDellPrep = pkgs.writeShellScriptBin "sun-dell-prep" ''
        ${config.programs.mango.package}/bin/mmsg dispatch create_virtual_output,SUNHEAD
        # The virtual output appears asynchronously after the dispatch.
        for i in 1 2 3 4 5; do
          sleep 0.2
          ${pkgs.wlr-randr}/bin/wlr-randr --output SUNHEAD --custom-mode 1366x768@60Hz && break
        done
      '';
    in {
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

          # Global on Linux (no per-app override exists). "SUNHEAD" is the
          # mango virtual output the DELL app creates in its prep-cmd; when
          # it does not exist, wlgrab falls back to the first real output
          # (eDP-1), which is exactly what "Desktop (Native)" wants.
          output_name = "SUNHEAD";

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
              # Plain desktop stream: no prep commands, sunshine captures the
              # current session whatever it is. output_name "SUNHEAD" does
              # not exist here -> wlgrab falls back to eDP-1 (see above).
              {
                name = "Desktop (Native)";
                image-path = "desktop.png";
              }
            ]
            ++ [
              # DELL-tuned stream: create the named virtual output (mango
              # IPC, mmsg ships in the mango package), let the host mango
              # monitorrule pin it to 1366x768@60 (DELL's native mode), and
              # give wlr-randr a safety re-assert with a short retry (the
              # output appears asynchronously after the dispatch). undo
              # destroys all virtual outputs; auto-detach mirrors the old
              # 3-app set.
              {
                name = "Desktop (dell-latitude-E7270-H836QF2)";
                image-path = "desktop.png";
                prep-cmd = [
                  {
                    do = "${sunDellPrep}/bin/sun-dell-prep";
                    undo = "${config.programs.mango.package}/bin/mmsg dispatch destroy_all_virtual_output";
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
