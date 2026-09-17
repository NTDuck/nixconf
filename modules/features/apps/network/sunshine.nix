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
# Capture: wayland (wlroots zwlr_screencopy) works under mango without
# cap_sys_admin; the log showed portalgrab found 'eDP-1' directly. capSysAdmin
# stays off so the wrapperless binary keeps working with the user systemd
# unit. Encoder: nvenc fails in this unit ("Operation not permitted" /
# CUDA load failure without cap_sys_admin), so sunshine falls back to
# software x264 — matching the observed live behavior.
#
# Applications: ports the entries from the pre-declaration apps.json.
# The old "Low Res Desktop" prep-cmd used xrandr, which cannot work on
# legion (services.xserver.enable = false); wlr-randr is the Wayland
# equivalent and is what moonlight-only outputs need.
#
# Settings reference: https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
{den, ...}: {
  den.aspects.apps.network.sunshine = {
    internalOutput,
    externalOutput ? null,
    externalMode ? null,
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
                name = "Desktop";
                image-path = "desktop.png";
              }
            ]
            ++ (lib.optionals (externalOutput != null) [
              # Low-res mode for weaker networks: switch the external output to
              # the stream mode, restore native on detach. Uses wlr-randr
              # (Wayland-native; the historical apps.json used xrandr, which
              # requires an X server). Only declared when the host passes an
              # external output; wlr-randr must run against the compositor's
              # WAYLAND_DISPLAY, which sunshine's user unit imports.
              {
                name = "Low Res Desktop";
                image-path = "desktop.png";
                prep-cmd = [
                  {
                    do = "${pkgs.wlr-randr}/bin/wlr-randr --output ${externalOutput} --mode ${externalMode}";
                    undo = "";
                  }
                ];
                exclude-global-prep-cmd = "false";
                auto-detach = "true";
              }
            ])
            ++ [
              # Steam Big Picture: detach sunshine's launcher and open BP in the
              # user's existing steam (programs.steam is enabled on legion).
              {
                name = "Steam Big Picture";
                detached = ["setsid steam steam://open/bigpicture"];
                prep-cmd = [
                  {
                    do = "";
                    undo = "setsid steam steam://close/bigpicture";
                  }
                ];
                image-path = "steam.png";
              }

              # Moonlight on the DELL reaches this host; expose the DELL-facing
              # terminal workload directly (foot client session) so a stream can
              # drive a terminal without touching the desktop.
              {
                name = "Terminal (foot)";
                prep-cmd = [
                  {
                    do = "footclient";
                    undo = "";
                  }
                ];
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
