# oh-my-pi (omp) — common harness aspect. Installed on both hosts:
#   - legion: full client, cloud providers via agenix secrets (+ local
#     ollama in the homelab spec, see the host-private aspect).
#   - dell: thin client; models.yml only in the remote specialisation
#     (host-private aspect), no agenix identity.
#
# This aspect owns the SHARED session pieces:
#   - pi-reasonix extension + REASONIX_* env (cache-first prefix work)
#   - config.default.yml (read-only overlay merged OVER mutable
#     config.yml via PI_CONFIG_FILES — see the alias below)
#   - the `omp` wrapper alias
#
# Alias merge semantics (the "2 aliases" trap): defining
# home.shellAliases.omp here AND in a host-private module raises the
# module-system duplicate-definition error (attrsets merge recursively,
# but leaf values must have exactly one definition unless wrapped in
# mkDefault/mkForce). Single source of truth: this aspect defines the
# alias with lib.mkDefault so a host COULD override; hosts define none.
{
  den,
  inputs,
  ...
}: let
  pi-reasonix = {
    pkgs,
    lib,
  }:
    pkgs.stdenv.mkDerivation rec {
      pname = "pi-reasonix";
      version = "1.1.0";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/pi-reasonix/-/pi-reasonix-${version}.tgz";
        hash = "sha512-pK9ig80y8l8shFoWGJx+ylg+dQ2qj9a/3z+nIkCDcsCW+3TsbqyeNrm0B/Pb4YcaczUjDBnVJHtByzbh+JJVzQ==";
      };

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/node_modules/pi-reasonix
        cp -r * $out/lib/node_modules/pi-reasonix/
        mkdir -p $out/share/omp/extensions
        ln -s $out/lib/node_modules/pi-reasonix/dist/extensions/index.js $out/share/omp/extensions/pi-reasonix.js
        runHook postInstall
      '';

      meta = {
        description = "DeepSeek-native optimizations for Pi / Oh-My-Pi: cache-first prefix stabilization, tool-call repair, and cost control";
        homepage = "https://github.com/TheTrebor/pi-reasonix";
        license = lib.licenses.mit;
      };
    };

  # Shared omp TUI defaults (moved from legion's private aspect
  # 2026-09-22): pure UI/behavior preferences with no host coupling, so
  # both hosts get the same baseline (dell's ascii override reverted to
  # the shared "nerd" 2026-09-25). modelRoles stay out — /model picks
  # belong in the mutable config.yml (PI_CONFIG_FILES merges this file
  # OVER it).
  defaultConfig = import ./_omp-default-config.nix;

  # API keys live in agenix on legion; dell has no agenix identity
  # enrolled (host comment: "keys are legion-only"), so the alias exports
  # a key ONLY when the host actually has the secret. Read via $(cat …)
  # at INVOCATION time (not activation) so rotations apply immediately.
  # Env name ≠ store attr: agenix attrs are kebab-case, exported names
  # SCREAMING — hence the pair list.
  secretExports = lib: osConfig:
    lib.concatStringsSep " \\\n" (map
      ({
        env,
        secret,
      }: ''${env}="$(cat ${osConfig.age.secrets.${secret}.path})"'')
      [
        {
          env = "CODEV_API_KEY";
          secret = "codev-api-key";
        }
        {
          env = "ORCAROUTER_API_KEY";
          secret = "orcarouter-api-key";
        }
        {
          env = "OPENCODE_API_KEY";
          secret = "opencode-api-key";
        }
        {
          env = "OPENROUTER_API_KEY";
          secret = "openrouter-api-key";
        }
        {
          env = "TABIAI_API_KEY";
          secret = "tabiai-api-key";
        }
      ]);
in {
  den.aspects.dev.agentics.harnesses.oh-my-pi = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp
        (pi-reasonix {
          inherit pkgs;
          inherit (pkgs) lib;
        })
      ];
    };

    homeManager = {
      config,
      lib,
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};
      reasonixPkg = pi-reasonix {
        inherit pkgs;
        inherit (pkgs) lib;
      };
      ompPkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;

      # Dell's HM eval has no age secrets at all (agenix aspect not
      # included), so osConfig.age.secrets is an empty attrset there —
      # guard the exports instead of forcing agenix onto every host.
      hasSecrets = (osConfig.age.secrets or {}) != {};
    in {
      home.file.".omp/agent/extensions/pi-reasonix.js".source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";

      # NOT ".omp/agent/config.yml": omp treats that file as mutable state
      # (writes setupVersion, /model picks, wizard results) and saving through
      # an HM store symlink dies with EROFS, which re-triggers the setup wizard
      # on every launch. This file is a read-only overlay merged OVER
      # config.yml via PI_CONFIG_FILES (set in the omp alias below).
      home.file.".omp/agent/config.default.yml".source =
        yaml.generate ".omp.agent.config.default.yml" defaultConfig;

      home.sessionVariables = {
        REASONIX_SCAVENGE = "1";
        REASONIX_RESULT_CAP_TOKENS = "3000";
      };

      home.shellAliases = {
        # mkDefault (not a bare value): a host-private aspect may override
        # the alias without a module-system duplicate-definition error.
        # Two bare `omp =` definitions (one here, one host-side) WOULD
        # collide at eval — that's the conflict this structure avoids.
        omp = lib.mkDefault ''
          ${lib.optionalString hasSecrets ''
            ${secretExports lib osConfig} \
          ''}
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${ompPkg}/bin/omp
        '';
      };
    };
  };
}
