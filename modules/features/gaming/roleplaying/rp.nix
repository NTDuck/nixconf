{den, ...}: {
  # RP Suite: local roleplay client (Express API + built SPA on one port).
  # https://github.com/pnotisdev/rp
  # Upstream ships only a Dockerfile — no registry image — and oci-containers
  # can only run pre-pulled/loaded images. The container is therefore built
  # with podman from the pinned source in preStart; buildah's layer cache makes
  # every rebuild after the first a no-op unless the pin changes.
  den.aspects.gaming.roleplaying.rp = {
    nixos = {
      pkgs,
      config,
      ...
    }: let
      # Pinned to master 2026-09-14 so the source hash stays reproducible;
      # bump rev + hash together when updating.
      src = pkgs.fetchFromGitHub {
        owner = "pnotisdev";
        repo = "rp";
        rev = "7a87835192728a89a69cf1a6fb09eeddc4172a51";
        hash = "sha256-qbHJMkCQupXlbqxEE8t8fHci6/cGQszbsA4PSSEEinY=";
      };
    in {
      virtualisation.podman.enable = true;

      systemd.services.podman-rp = {
        description = "RP Suite (roleplay client)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"];
        after = ["network-online.target"];

        path = [config.virtualisation.podman.package];

        preStart = ''
          podman rm -f rp || true
          rm -f /run/podman-rp/ctr-id
          podman build -t rp-suite:local ${src}
        '';

        script = ''
          exec podman run \
            --name=rp \
            --log-driver=journald \
            --cidfile=/run/podman-rp/ctr-id \
            --cgroups=enabled \
            --sdnotify=conmon \
            -d --replace \
            --pull=never \
            -p 127.0.0.1:3001:3001 \
            -v /var/lib/rp:/app/data \
            -e TZ=UTC \
            rp-suite:local
        '';

        preStop = "podman stop --ignore --cidfile=/run/podman-rp/ctr-id";
        postStop = "podman rm -f --ignore --cidfile=/run/podman-rp/ctr-id";

        serviceConfig = {
          Type = "notify";
          NotifyAccess = "all";
          Delegate = true;
          RuntimeDirectory = "podman-rp";
          StateDirectory = "rp";
          Environment = "PODMAN_SYSTEMD_UNIT=%n";
          # First build pulls node:24-slim and runs npm ci — unbounded.
          TimeoutStartSec = 0;
          TimeoutStopSec = 120;
          Restart = "on-failure";
        };
      };
    };
  };
}
