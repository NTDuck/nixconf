# gods-eye-view v0.2.1 (https://github.com/bilawalsidhu/gods-eye-view) —
# "A spy-satellite simulator in your browser": photorealistic 3D globe with
# live aircraft/ships/satellites/earthquakes/CCTV and optional voice control.
#
# WHY A DEV SERVER, NOT A BUILD (architectural, decided 2026-10-19): the app
# has NO production server mode. `vite build` only emits a static client
# bundle; every API proxy (ADS-B, AIS, Overpass, OpenAI Realtime, CCTV, ...)
# lives in Vite's DEV middleware (server/providers/local.js wired through
# server/standalone/vite.config.js). Upstream's own Dockerfile ships
# `node scripts/docker-start.mjs` — a dev-server wrapper — as the production
# entry point. So the NixOS service runs the same dev server, loopback-only.
#
# WHY A STATE COPY, NOT THE STORE TREE: the dev server writes into its root —
# repo-root `.env` (Provider Settings persists keys via key-setup.js's
# defaultSourceRoot), `.gev-cache` (providers cache via process.cwd()),
# `.gev-logs`, and Vite's dep-optimizer cache (`node_modules/.vite`). A
# /nix/store path is read-only, so ExecStartPre mirrors the store tree into
# StateDirectory (gods-eye-view-sync, marker-gated per store version) and the
# server runs with root=that copy. Mirrors upstream compose.yaml's bind-mount
# model. `.env` is preserved across version bumps; caches regenerate. Full
# copy (~430 MB incl. node_modules) NOT hardlinked: vite writes into
# node_modules/.vite inside the copy, which would corrupt store content
# through hardlinks. The state-root cwd keeps .gev-cache OUTSIDE the copy so
# it survives version bumps.
#
# SECURITY POSTURE (matches compose.yaml): binds 127.0.0.1:4173 only. The
# server brokers whatever provider keys are configured; the README warns that
# any non-loopback publish exposes them to the LAN. Host-header allowlist
# stays localhost/127.0.0.1 (GEV_ALLOWED_HOSTS unset); Provider Settings
# admits loopback peers only (no docker gateway trust — that logic is
# container-NAT-specific).
#
# PUPPETEER_SKIP_DOWNLOAD at build: puppeteer is a QA-scripts-only devDep;
# without the env var npm ci pulls ~150 MB of Chromium that never runs here.
# sharp's native binding ships prebuilt (@img/sharp-linux-x64) via npm ci.
{den, ...}: {
  den.aspects.apps.gods-eye-view = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "gods-eye-view";
      version = "0.2.1";
      port = 4173;
      stateDir = "/var/lib/gods-eye-view";
      repoDir = "${stateDir}/repo";

      gods-eye-view = pkgs.buildNpmPackage {
        inherit pname version;

        src = pkgs.fetchFromGitHub {
          owner = "bilawalsidhu";
          repo = "gods-eye-view";
          rev = "v${version}";
          hash = "sha256-V4MXFts1h5XUKMGTu0MZg+SE4Hb2m7CpFBeyVOF2is0=";
        };

        npmDepsHash = "sha256-LU/ffIoGMiNNdMxwnjWL12sjLup9Co+xxudDpRt6seA=";

        # No `vite build`: the dev server IS the app (see header). Pruning
        # would strip vite/sharp/ws — all devDependencies here.
        dontNpmBuild = true;
        dontNpmPrune = true;

        env.PUPPETEER_SKIP_DOWNLOAD = "1";

        nativeBuildInputs = [pkgs.makeWrapper];

        # Launcher inside the package tree so `import('vite')` resolves the
        # store's node_modules while createServer({root}) points at the
        # writable state copy. Mirrors scripts/pinokio-start.mjs minus the
        # Pinokio hooks and docker-start.mjs minus the container-gateway
        # trust (on bare metal the browser arrives from loopback, which
        # Provider Settings already admits).
        postPatch = ''
          cat << 'GEV_SERVE' > scripts/gev-serve.mjs
#!/usr/bin/env node
import { createServer } from 'vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const pkgRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repo = process.argv[2] || process.env.GEV_REPO || pkgRoot;
const port = Number.parseInt(process.env.PORT ?? "", 10) || 4173;
const host = process.env.HOST || "127.0.0.1";

const server = await createServer({
  root: repo,
  configFile: path.join(repo, "vite.config.js"),
  server: {host, port, strictPort: true},
});
await server.listen();
server.printUrls();
console.log("[gev] serving " + repo + " at http://localhost:" + port + "/");

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.once(signal, () => {
    server.close().finally(() => process.exit(0));
  });
}
GEV_SERVE
        '';

        postInstall = ''
          makeWrapper ${lib.getExe pkgs.nodejs} $out/bin/gods-eye-view \
            --add-flags "$out/lib/node_modules/gods-eye-view/scripts/gev-serve.mjs"

          # Marker-gated mirror of the store tree into the state dir. Runs as
          # the unit's User before every start. --reflink=auto: CoW where the
          # fs supports it, else a plain copy — never hardlinks (vite writes
          # node_modules/.vite inside the copy).
          cat << GEV_SYNC > $out/bin/gods-eye-view-sync
#!/usr/bin/env bash
set -euo pipefail
SRC="$out/lib/node_modules/gods-eye-view"
REPO="\''${GEV_REPO:-${repoDir}}"
STATE="\$(dirname "\$REPO")"
MARKER="\$STATE/.gev-store-marker"
if [ -f "\$MARKER" ] && [ "\$(cat "\$MARKER")" = "\$SRC" ] && [ -d "\$REPO" ]; then
  exit 0
fi
mkdir -p "\$STATE"
rm -rf "\$REPO.new"
cp -a --reflink=auto "\$SRC" "\$REPO.new"
# cp -a preserves the store's read-only modes; esbuild must write
# vite.config.js.timestamp-*.mjs next to the config, and Vite may touch
# node_modules/.vite — so the whole tree becomes writable. The tree is
# user-owned single-purpose state; broad chmod is safe here.
chmod -R u+w "\$REPO.new"
# User credentials survive version bumps; caches do not (regenerable).
if [ -f "\$REPO/.env" ]; then
  mv "\$REPO/.env" "\$REPO.new/.env"
fi
rm -rf "\$REPO.old"
if [ -d "\$REPO" ]; then
  mv "\$REPO" "\$REPO.old"
fi
mv "\$REPO.new" "\$REPO"
rm -rf "\$REPO.old"
printf '%s' "\$SRC" > "\$MARKER"
GEV_SYNC
          chmod +x $out/bin/gods-eye-view-sync
        '';

        meta = {
          description = "Real-time 3D globe intelligence console: live aircraft, ships, satellites, earthquakes and CCTV";
          homepage = "https://github.com/bilawalsidhu/gods-eye-view";
          changelog = "https://github.com/bilawalsidhu/gods-eye-view/releases/tag/v${version}";
          license = lib.licenses.mit;
          mainProgram = "gods-eye-view";
          platforms = lib.platforms.linux;
        };
      };
    in {
      environment.systemPackages = [gods-eye-view];

      systemd.services.gods-eye-view = {
        description = "God's Eye View — local geospatial intelligence console (loopback-only dev server)";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "simple";
          User = "ayin";
          StateDirectory = "gods-eye-view";
          WorkingDirectory = stateDir;
          ExecStartPre = "${gods-eye-view}/bin/gods-eye-view-sync";
          ExecStart = "${lib.getExe gods-eye-view}";
          Restart = "on-failure";
          RestartSec = 5;

          # Loopback-only bind; widening is a deliberate user act via
          # override, never the default (see header). GEV_REPO is the
          # launcher's writable-root contract (env, not argv, so the bin is
          # also usable standalone with an explicit GEV_REPO).
          Environment = [
            "HOST=127.0.0.1"
            "PORT=${toString port}"
            "GEV_REPO=${repoDir}"
          ];

          # The app only needs the network and its state dir.
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
          LockPersonality = true;
        };
      };
    };
  };
}
