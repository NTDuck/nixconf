# gods-eye-view v0.2.1 (https://github.com/bilawalsidhu/gods-eye-view) —
# "A spy-satellite simulator in your browser": photorealistic 3D globe with
# live aircraft/ships/satellites/earthquakes/CCTV and optional voice control.
#
# WHY PODMAN, NOT A NIX BUILD (2026-10-19 cutover from buildNpmPackage): the
# app has NO production mode — `vite build` only emits a static client bundle;
# every API proxy (ADS-B, AIS, Overpass, OpenAI Realtime, CCTV, ...) lives in
# Vite's DEV middleware (server/providers/local.js wired through
# server/standalone/vite.config.js). Upstream ships the app as a dev-server
# container (Dockerfile on main, compose.yaml), so a container is the honest
# deployment unit. Also drops the ~430 MB store-mirror state copy the Nix
# package needed (dev server writes into its root).
#
# WHY OUR OWN DOCKERFILE: the v0.2.1 tag has no Dockerfile — container support
# (Dockerfile/compose/scripts/docker-start.mjs) exists only on main, a dev
# branch. The image below is adapted from main's, minus the apt git install
# (only the test suite needs git) and the docker-gateway launcher. Pinned to
# main's exact base: node:24.14.0-slim by digest (same Node as CI,
# engines >=24.14.0).
#
# WHY --network=host (structural loopback-only): vite binds 127.0.0.1 in the
# HOST netns — no -p publish exists to widen by accident, and the browser
# arrives from loopback, so Provider Settings' loopback-only admission admits
# the host machine with NO trusted-peers/gateway logic. That gateway hack is
# the entire reason main's scripts/docker-start.mjs exists; host networking
# deletes the problem instead of solving it. Widening exposure requires a
# deliberate --network change, never a flag default.
#
# ENTRYPOINT IS THE VITE CLI, NOT A CUSTOM LAUNCHER: `vite --host --port
# --strictPort` with cwd=/app auto-loads vite.config.js (plugins + API
# proxies) exactly like main's createServer call. docker-start.mjs is absent
# at the tag anyway.
#
# STATE (mirrors upstream compose.yaml's mount philosophy): the image owns
# source + node_modules (sharp et al are Linux-compiled; upstream compose
# explicitly shadows node_modules rather than bind-mounting a host copy).
# Only what the app writes is persisted on the host, bind-mounted in:
#   /var/lib/gods-eye-view/.env      — Provider Settings credential store
#                                      (key-setup.js writes repo-root .env)
#   /var/lib/gods-eye-view/gev-cache — provider caches (process.cwd()-based)
#   /var/lib/gods-eye-view/gev-logs  — app logs
# .env survives version bumps (image rebuild does not touch it); caches are
# regenerable. Vite's dep-optimizer cache lives in the writable container
# layer (node_modules/.vite) and regenerates per image — deliberately not
# persisted.
#
# BUILD MODEL (rp.nix convention): upstream has no registry image and
# oci-containers only runs pre-pulled images, so preStart builds from the
# pinned fetchFromGitHub source (buildah layer cache makes rebuilds no-ops)
# and script runs it. First start pulls node:24-slim and runs npm ci —
# unbounded, hence TimeoutStartSec=0.
{den, ...}: {
  den.aspects.apps.gods-eye-view = {
    nixos = {
      pkgs,
      config,
      ...
    }: let
      version = "0.2.1";
      port = 4173;

      src = pkgs.fetchFromGitHub {
        owner = "bilawalsidhu";
        repo = "gods-eye-view";
        rev = "v${version}";
        hash = "sha256-V4MXFts1h5XUKMGTu0MZg+SE4Hb2m7CpFBeyVOF2is0=";
      };

      dockerfile = pkgs.writeText "gods-eye-view-Dockerfile" ''
        # Adapted from upstream main's Dockerfile (base digest identical);
        # see module header for the deltas (no apt git, no docker-start).
        FROM node:24.14.0-slim@sha256:d8e448a56fc63242f70026718378bd4b00f8c82e78d20eefb199224a4d8e33d8

        # Puppeteer is a QA-scripts-only devDep; skip its ~150MB Chromium.
        ENV PUPPETEER_SKIP_DOWNLOAD=1

        WORKDIR /app
        USER node

        COPY --chown=node:node package.json package-lock.json ./
        RUN npm ci

        COPY --chown=node:node . .

        EXPOSE 4173
        # Shell form so PORT stays operator-overridable via podman -e.
        CMD ["sh", "-c", "exec node node_modules/vite/bin/vite.js --host 127.0.0.1 --port ''${PORT:-4173} --strictPort"]
      '';

      stateDir = "/var/lib/gods-eye-view";
    in {
      virtualisation.podman.enable = true;

      systemd.services.podman-gods-eye-view = {
        description = "God's Eye View — local geospatial intelligence console (loopback-only dev server, podman)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];

        path = [config.virtualisation.podman.package];

        preStart = ''
          podman rm -f gods-eye-view || true
          rm -f /run/podman-gev/ctr-id
          # Credential store must exist as a FILE before the bind mount
          # (podman bind-creates missing sources as directories). Rootful
          # podman maps container uids 1:1 onto host uids, so chown 1000
          # (the image's `node` user) makes every state bind writable by
          # the app — same fix-up the rp.nix precedent uses. Do NOT add
          # --userns=keep-id: it is rootless-only semantics and under
          # rootful maps host-root into the container, leaving these
          # host-1000 files unmapped/unwritable (checked podman-run(1)).
          if [ ! -f "${stateDir}/.env" ]; then
            touch "${stateDir}/.env"
          fi
          chown 1000:1000 "${stateDir}/.env"
          mkdir -p "${stateDir}/gev-cache" "${stateDir}/gev-logs"
          chown -R 1000:1000 "${stateDir}/gev-cache" "${stateDir}/gev-logs"
          podman build -f ${dockerfile} -t gods-eye-view:local ${src}
        '';

        script = ''
          exec podman run \
            --name=gods-eye-view \
            --log-driver=journald \
            --cidfile=/run/podman-gev/ctr-id \
            --cgroups=enabled \
            --sdnotify=conmon \
            -d --replace \
            --network=host \
            -v ${stateDir}/.env:/app/.env \
            -v ${stateDir}/gev-cache:/app/.gev-cache \
            -v ${stateDir}/gev-logs:/app/.gev-logs \
            -e TZ=UTC \
            -e PORT=${toString port} \
            gods-eye-view:local
        '';

        preStop = "podman stop --ignore --cidfile=/run/podman-gev/ctr-id";
        postStop = "podman rm -f --ignore --cidfile=/run/podman-gev/ctr-id";

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Delegate = true;
          RuntimeDirectory = "podman-gev";
          StateDirectory = "gods-eye-view";
          Environment = "PODMAN_SYSTEMD_UNIT=%n";
          # First build pulls node:24-slim and runs npm ci — unbounded.
          TimeoutStartSec = 0;
          TimeoutStopSec = 120;
          Restart = "on-failure";
        };
      };

      # Terminal invocation (sillytavern/rp convention): CLI command instead
      # of a desktop entry. Waits briefly for the loopback port (the unit may
      # still be building/starting), opens the web UI quietly (xdg-open
      # prints portal noise on stdout), then streams the unit journal —
      # Ctrl+C ends the stream, the browser stays open. Absolute paths for
      # xdg-open/journalctl: writeShellScriptBin scripts get neither
      # xdg-utils nor systemd on their PATH.
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "gods-eye-view" ''
          port=${toString port}
          for _ in $(seq 1 20); do
            if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
              ${pkgs.xdg-utils}/bin/xdg-open "http://127.0.0.1:$port" >/dev/null
              echo "gods-eye-view: streaming podman-gods-eye-view logs — Ctrl+C to stop (browser stays open)"
              exec ${pkgs.systemd}/bin/journalctl --no-pager -n 5 -fu podman-gods-eye-view
            fi
            sleep 0.5
          done
          echo "gods-eye-view: http://127.0.0.1:$port not reachable after 10s — check: systemctl status podman-gods-eye-view" >&2
          exit 1
        '')
      ];
    };
  };
}
