# gemini-web2api-go (https://github.com/zexadev/gemini-web2api-go) —
# self-hosted reverse proxy that turns the Gemini web UI into an
# OpenAI-compatible /v1/chat/completions API. Single Go binary; admin
# dashboard; cookies managed at runtime through the dashboard and stored in
# the container's SQLite DB.
#
# WHY A HAND-ROLLED PODMAN UNIT, NOT oci-containers (architectural, decided
# 2026-10-20): virtualisation.oci-containers.backend is GLOBAL — setting it
# to "podman" here would silently re-platform every other container on the
# host (sillytavern runs docker on legion). Upstream GHCR also only ships a
# distroless OCI index, which the docker-backed oci-containers module pulls
# fine, so the backend flip would buy nothing. The rp.nix unit is the repo's
# podman-service precedent: rootful podman via virtualisation.podman.enable
# + a systemd unit wrapping podman run. Digest-pinned like sillytavern so
# the pull is exactly this index — immune to upstream drift of the floating
# `latest` tag.
#
# RUNTIME CONFIG GOES IN THE DASHBOARD, NOT HERE: tuning (rate limits,
# retries, TLS fingerprint), credentials (API key, Google cookies) and the
# admin token all live in the panel backed by the DB. The compose env vars
# are optional lock-down switches; none are set by default so the first
# boot auto-generates the API key and the panel token stays empty (loopback
# bind only — compose's own comment marks unauthenticated non-loopback as
# unacceptable).
#
# DATA IS A NAMED VOLUME, NOT A BIND MOUNT (upstream compose comment): the
# image runs as uid 65532; a root-owned auto-created host dir breaks SQLite
# with `unable to open database file (14)`. Named volumes inherit the
# image's ownership. Upstream compose names it gw2a-data.
{den, ...}: {
  den.aspects.apps.gemini-web2api-go = {
    nixos = {
      pkgs,
      config,
      ...
    }: let
      port = 8083;
      # GHCR `latest` index digest (2026-10-20, upstream push 2026-10-19).
      imageRef = "ghcr.io/zexadev/gemini-web2api-go@sha256:36e1a57cfcadba8531a44cfcf1a170e0228ce3cc92688576b96563d201f6d4e9";
    in {
      # Rootful podman is the systemd-managed runtime for the unit below
      # (the HM podman socket aspect alone doesn't run system units).
      virtualisation.podman.enable = true;

      systemd.services.podman-gemini-web2api = {
        description = "gemini-web2api-go (Gemini web → OpenAI-compatible API)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];

        path = [config.virtualisation.podman.package];

        preStart = ''
          podman rm -f gemini-web2api || true
          rm -f /run/podman-gemini-web2api/ctr-id
        '';

        script = ''
          # Loopback-only publish (upstream compose posture): the admin
          # panel is unauthenticated by default, and /v1/* may hold the
          # auto-generated key; widening is a deliberate user act.
          # Named volume gw2a-data keeps /data owned by the image's
          # nonroot uid (see header).
          exec podman run \
            --name=gemini-web2api \
            --log-driver=journald \
            --cidfile=/run/podman-gemini-web2api/ctr-id \
            --cgroups=enabled \
            --sdnotify=conmon \
            -d --replace \
            -p 127.0.0.1:${toString port}:${toString port} \
            -v gw2a-data:/data \
            --health-cmd='/app/gemini-web2api --version' \
            --health-interval=30s \
            --health-timeout=5s \
            --health-retries=3 \
            ${imageRef}
        '';

        preStop = "podman stop --ignore --cidfile=/run/podman-gemini-web2api/ctr-id";
        postStop = "podman rm -f --ignore --cidfile=/run/podman-gemini-web2api/ctr-id";

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Delegate = true;
          RuntimeDirectory = "podman-gemini-web2api";
          Environment = "PODMAN_SYSTEMD_UNIT=%n";
          # First pull of the distroless image is network-bound.
          TimeoutStartSec = 0;
          TimeoutStopSec = 120;
          Restart = "on-failure";
        };
      };

      # Terminal invocation (pattern from the sillytavern aspect): CLI
      # command instead of a desktop entry. Waits briefly for the loopback
      # port, opens the admin dashboard quietly (xdg-open prints portal
      # noise on stdout), then streams the unit journal — Ctrl+C ends the
      # stream, the browser stays open. Absolute paths for xdg-open/
      # journalctl: writeShellScriptBin scripts get neither xdg-utils nor
      # systemd on their PATH.
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "gemini-web2api" ''
          port=${toString port}
          for _ in $(seq 1 20); do
            if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
              ${pkgs.xdg-utils}/bin/xdg-open "http://127.0.0.1:$port" >/dev/null
              echo "gemini-web2api: streaming podman-gemini-web2api logs — Ctrl+C to stop (browser stays open)"
              exec ${pkgs.systemd}/bin/journalctl --no-pager -n 5 -fu podman-gemini-web2api
            fi
            sleep 0.5
          done
          echo "gemini-web2api: http://127.0.0.1:$port not reachable after 10s — check: systemctl status podman-gemini-web2api" >&2
          exit 1
        '')
      ];
    };
  };
}
