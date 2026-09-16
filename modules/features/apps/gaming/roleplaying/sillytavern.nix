{den, ...}: {
  # SillyTavern: self-hosted AI roleplay frontend.
  # Official image: ghcr.io/sillytavern/sillytavern (compose in docker/docker-compose.yml).
  # Digest-pinned in the image ref: podman pulls exactly this index, immune to
  # upstream drift of the floating `latest` tag.
  den.aspects.apps.gaming.roleplaying.sillytavern = {
    nixos = {pkgs, ...}: {
      virtualisation.oci-containers.containers.sillytavern = {
        image = "ghcr.io/sillytavern/sillytavern@sha256:5bb7ef334602ad72b29351acae4d9744ce16c99a1fab840acbd42a7d49d27d9b";

        # Esoteric high port (user 2026-09-16): avoid common dev-port
        # collisions (8000 is a very common web/API dev port). The server
        # binds 8000 inside the container; only the host side is remapped.
        ports = ["127.0.0.1:43999:8000"];

        volumes = [
          # Mirrors the official compose mounts; config/ holds config.yaml,
          # data/ holds user+character data, third-party/ is extensions dir.
          "sillytavern-config:/home/node/app/config"
          "sillytavern-data:/home/node/app/data"
          "sillytavern-plugins:/home/node/app/plugins"
          "sillytavern-extensions:/home/node/app/public/scripts/extensions/third-party"
        ];

        environment = {
          NODE_ENV = "production";
        };

        # From the official compose healthcheck.
        extraOptions = [
          "--health-cmd=node src/healthcheck.js"
          "--health-interval=30s"
          "--health-timeout=10s"
          "--health-start-period=20s"
          "--health-retries=3"
        ];
      };

      # Terminal invocation (user 2026-09-16): CLI command instead of a
      # desktop entry; opens the web UI on the loopback port.
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "sillytavern" ''
          exec xdg-open http://127.0.0.1:43999
        '')
      ];
    };
  };
}
