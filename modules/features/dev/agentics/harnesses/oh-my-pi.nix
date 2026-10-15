# oh-my-pi (omp) — common harness aspect. Installed on both hosts:
#   - legion: full client, cloud providers via agenix secrets (+ local
#     ashalliants in the homelab spec, see the host-private aspect).
#   - dell: thin client; models.yml only in the remote specialisation
#     (host-private aspect), no agenix identity.
#
# This aspect owns the SHARED session pieces:
#   - config.default.yml (read-only overlay merged OVER mutable
#     config.yml via PI_CONFIG_FILES — see the alias below)
#   - the `omp` wrapper alias
#
# pi-reasonix extension + REASONIX_* env + secretExports were removed
# 2026-10-12: pi-reasonix is a per-profile concern (the legion ompl
# profile keeps its own copy in its host-private aspect); secretExports
# is a per-host concern (only legion has agenix). Keeping them here
# forced every host to evaluate the agenix path and the npm fetchurl.
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
  # Shared omp TUI defaults (moved from legion's private aspect
  # 2026-09-22): pure UI/behavior preferences with no host coupling, so
  # both hosts get the same baseline (dell's ascii override reverted to
  # the shared "nerd" 2026-09-25). modelRoles stay out — /model picks
  # belong in the mutable config.yml (PI_CONFIG_FILES merges this file
  # OVER it).
  defaultConfig = import "${inputs.self}/modules/features/dev/agentics/harnesses/_omp-default-config.nix";
in {
  den.aspects.dev.agentics.harnesses.oh-my-pi = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.omp.packages.${pkgs.stdenv.hostPlatform.system}.omp
      ];
    };

    homeManager = {pkgs, ...}: let
      yaml = pkgs.formats.yaml {};
      ompPkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
    in {
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
          ${ompPkg}/bin/omp
        '');
      };
    };
  };
}
