# oh-my-pi (omp) — common harness aspect. Installed on both hosts:
#   - legion: full client, cloud providers via agenix secrets (+ local
#     ninfer in the homelab spec, see the host-private aspect).
#   - dell: thin client; models.yml only in the remote specialisation
#     (host-private aspect), no agenix identity.
#
# This aspect owns the SHARED session pieces:
#   - config.default.yml (read-only overlay merged OVER mutable
#     config.yml via PI_CONFIG_FILES — see the alias below)
#   - the `omp` wrapper alias
#
# pi-reasonix extension + REASONIX_* env + secretExports were removed
# 2026-10-12: secretExports is a per-host concern (only legion has
# agenix) and keeping it here forced every host to evaluate the agenix
# path. 2026-10-20: pi-reasonix restored to this SHARED aspect (user
# request "enable back pi-reasonix") — dell was reasonix-less since the
# removal and the legion-private REASONIX_* env exports were inert
# without the shared extension file; same day, PI_STREAM_* watchdog env
# added (see sessionVariables below). secretExports stays per-host.
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
  lib,
  ...
}: let
  # pi-reasonix extension derivation (restored 2026-10-20, exact shape
  # of the pre-9011d32 block) lives in the sibling _pi-reasonix.nix.

  # omp from the upstream release binary (2026-11-09) — see
  # _omp-release.nix for the derivation, pin, and rationale.

  # Shared omp TUI defaults (moved from legion's private aspect
  # 2026-09-22): pure UI/behavior preferences with no host coupling, so
  # both hosts get the same baseline (dell's ascii override reverted to
  # the shared "nerd" 2026-09-25). modelRoles stay out — /model picks
  # belong in the mutable config.yml (PI_CONFIG_FILES merges this file
  # OVER it).
in {
  den.aspects.dev.agentics.harnesses.oh-my-pi = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = [
        # Release binary (2026-11-09): upstream omp-linux-x64 from GitHub
        # releases, hash-pinned, interpreter-only patchelf to the store
        # glibc (see _omp-release.nix; autoPatchelfHook breaks the bun
        # embedded bundle). Replaces the llm-agents source build (~10min
        # bun+cargo per bump); bumps are download-only everywhere. NOT
        # the upstream flake (inputs.omp) — that always builds from
        # source.
        (import "${inputs.self}/modules/features/dev/agentics/harnesses/_omp-release.nix" {inherit pkgs lib;})
        (import "${inputs.self}/modules/features/dev/agentics/harnesses/_pi-reasonix.nix" {
          inherit pkgs lib;
        })
      ];
    };

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.file.".omp/agent/extensions/pi-reasonix.js".source =
        "${(import "${inputs.self}/modules/features/dev/agentics/harnesses/_pi-reasonix.nix" {inherit pkgs lib;})}/share/omp/extensions/pi-reasonix.js";
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
        (pkgs.formats.yaml {}).generate ".omp.agent.config.default.yml"
        (import "${inputs.self}/modules/features/dev/agentics/harnesses/_omp-default-config.nix");

      # Stream watchdog env (2026-10-20): gemini-3.8-flash turns died
      # "Request was aborted" after ~60.2s on three consecutive attempts
      # (session JSONL: stopReason "error", retryRecovery, durations
      # 60161/60283/60290ms) while agy CLI and other models were fine.
      # Root cause (18.12.1/18.12.3 binary + ~/.omp/agent/models.db
      # model_cache): the google-antigravity catalog descriptor pins
      # compat.streamFirstEventTimeoutMs = 60000 (also on gemini-2.5-
      # flash / 3.1-flash-image); the provider resolves
      # env ?? (compat ?? 300000) and the env REPLACES the fallback
      # (normalizeIdleTimeoutMs, not Math.max) — so
      # PI_STREAM_FIRST_EVENT_TIMEOUT_MS=300000 restores the platform
      # default. NO idle override: PI_STREAM_IDLE_TIMEOUT_MS would
      # replace the already-300s idle default, only shrinking headroom.
      # sessionVariables (not the alias) so BOTH hosts and BOTH aliases
      # inherit them. REASONIX_* restored alongside the pi-reasonix
      # extension.
      home.sessionVariables = {
        ANTIGRAVITY_NO_KEEPALIVE = "1";
        PI_STREAM_FIRST_EVENT_TIMEOUT_MS = "300000";
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
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${import "${inputs.self}/modules/features/dev/agentics/harnesses/_omp-release.nix" {inherit pkgs lib;}}/bin/omp
        '');
      };
    };
  };
}
