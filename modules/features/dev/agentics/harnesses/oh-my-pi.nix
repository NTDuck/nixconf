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
  #
  # Each export GUARDS against an empty or placeholder secret: omp
  # resolves `apiKey: "NAME"` as `$envExact(NAME) || NAME`, so an empty
  # value makes omp send the literal name ("CODEV****_KEY") as the
  # bearer token — a 401 from the gateway that looks like a config bug.
  # Guarded export fails fast with the offending secret's path instead.
  # (2026-09-26: orcarouter-api-key decrypted empty — provider disabled
  # in legion's models.yml and the export commented out here; re-enable
  # when the key is restored.)
  secretExports = lib: osConfig:
    lib.concatStringsSep " \\\n" (map
      ({
        env,
        secret,
      }: let
        path = "${osConfig.age.secrets.${secret}.path}";
      in ''${env}="$(cat ${path})"; if [ -z "''${${env}}" ] || [[ "''${${env}}" == *_KEY ]]; then echo "omp: secret ${path} is empty or a placeholder" >&2; return 1 2>/dev/null || exit 1; fi;'')
      [
        {
          env = "CODEV_API_KEY";
          secret = "codev-api-key";
        }
        # ORCAROUTER DISABLED (2026-09-26): orcarouter-api-key.age is 0
        # bytes (key lost; re-fetch from orcarouter.ai and run `agenix -e
        # secrets/orcarouter-api-key.age`). Re-enable by uncommenting this
        # entry AND the orcarouter provider block in the legion host's
        # private harness aspect.
        # {
        #   env = "ORCAROUTER_API_KEY";
        #   secret = "orcarouter-api-key";
        # }
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

      # Ctrl+V remap (2026-09-25 user report: "when ctrl v it says keycap
      # picture insert mode instead of pasting"): omp binds
      # app.clipboard.pasteImage to ctrl+v by default (getDefaultPaste-
      # ImageKeys, linux = ["ctrl+v"]) — with an image on the clipboard
      # it inserts an image attachment chip instead of pasting text.
      # Moving pasteImage to alt+v leaves ctrl+v to the composer's
      # bracketed-paste path (plain text), which is what a terminal
      # workflow expects. Lives in the agent dir as keybindings.yml
      # (resolveKeybindingsConfigPaths reads keybindings.{yml,yaml,json}
      # from the agent dir).
      home.file.".omp/agent/keybindings.yml".text = ''
        keybindings:
          app.clipboard.pasteImage: "alt+v"
      '';

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
        #
        # .trim (2026-09-26): a trailing newline in the alias VALUE is a
        # command SEPARATOR in zsh — `omp -p …` then runs `-p …` as its
        # own command ("zsh: command not found: -p"). The value must end
        # exactly at the binary path.
        omp = lib.mkDefault (lib.removeSuffix "\n" ''
          ${lib.optionalString hasSecrets ''
            ${secretExports lib osConfig} \
          ''}
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${ompPkg}/bin/omp
        '');
      };
    };
  };
}
