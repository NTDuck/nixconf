{den, ...}: {
  den.aspects.dev.gitlab-runner = {
    # NixOS Wiki GitLab runner (first approach: docker-executor with Nix store caching):
    # https://wiki.nixos.org/wiki/Gitlab_runner
    includes = [
      den.aspects.system.virtualization.docker
    ];

    nixos = {
      lib,
      pkgs,
      ...
    }: {
      # 2026-10-30: Docker container egress networking requires IPv4 forwarding enabled
      # on the host to reach GitLab instances and external networks.
      boot.kernel.sysctl."net.ipv4.ip_forward" = true;

      services.gitlab-runner = {
        enable = true;
        services = {
          # Runner for building in docker via host's nix-daemon (nix store mounted read-only).
          nix = with lib; {
            # File should contain at least:
            # CI_SERVER_URL=<url>
            # REGISTRATION_TOKEN=<token>
            # Quoted absolute path ensures tokens do not leak into the nix store.
            registrationConfigFile = "/etc/gitlab-runner/ci-env";
            dockerImage = "alpine";
            dockerVolumes = [
              "/nix/store:/nix/store:ro"
              "/nix/var/nix/db:/nix/var/nix/db:ro"
              "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
            ];
            dockerDisableCache = true;
            preBuildScript = pkgs.writeScript "setup-container" ''
              mkdir -p -m 0755 /nix/var/log/nix/drvs
              mkdir -p -m 0755 /nix/var/nix/gcroots
              mkdir -p -m 0755 /nix/var/nix/profiles
              mkdir -p -m 0755 /nix/var/nix/temproots
              mkdir -p -m 0755 /nix/var/nix/userpool
              mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
              mkdir -p -m 1777 /nix/var/nix/profiles/per-user
              mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
              mkdir -p -m 0700 "$HOME/.nix-defexpr"
              . ${pkgs.nix}/etc/profile.d/nix-daemon.sh
              # 2026-10-30: Use modern nixos-unstable channel rather than the wiki's historical 20.09.
              ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs
              ${pkgs.nix}/bin/nix-channel --update nixpkgs
              ${pkgs.nix}/bin/nix-env -i ${concatStringsSep " " (with pkgs; [nix cacert git openssh])}
            '';
            environmentVariables = {
              ENV = "/etc/profile";
              USER = "root";
              NIX_REMOTE = "daemon";
              PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
              NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
            };
            tagList = ["nix"];
          };
        };
      };

      # 2026-10-30: ConditionPathExists prevents gitlab-runner service startup
      # failure during nixos-rebuild until /etc/gitlab-runner/ci-env is populated.
      systemd.services.gitlab-runner.unitConfig.ConditionPathExists = [
        "/etc/gitlab-runner/ci-env"
      ];

      # Prepare /etc/gitlab-runner directory for the ci-env configuration.
      systemd.tmpfiles.rules = [
        "d /etc/gitlab-runner 0750 root root -"
      ];
    };
  };
}
