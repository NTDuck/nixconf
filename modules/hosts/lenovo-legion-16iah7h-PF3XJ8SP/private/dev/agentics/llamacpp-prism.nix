# llamacpp-prism-up / llamacpp-prism-down — arbitrate the 3090 between the
# Ternary Bonsai 2 llama-server (bonsai2.service, prism-ml fork) and ollama.
#
# WHY THIS EXISTS (2026-09-20): both 27B daemons want the 3090 and cannot be
# resident together (bonsai 192K ctx ≈ 19 GiB; ollama 27B q4_K_M + KV ≈ 18
# GiB; card has 24 GiB). The old shared /run/egpu/ollama.env pin made them
# co-resident, which degraded ollama's 27B loads to 34/66 GPU layers @
# 1.6 tok/s (client timeouts → "404/no output"). User decision (2026-09-20,
# ask): swap-helper arbitration — exactly one daemon resident at a time,
# mmap loads make switches fast (bonsai: ~6 s; ollama 27B: ~10-20 s).
# Renamed from `model-swap` on the same day (user request): the interface
# is `llamacpp-prism-up` (bonsai2's prism llama-server takes the 3090) /
# `llamacpp-prism-down` (back to ollama).
#
# GPU pins stay as they are: ollama → 3090 only (services.ollama
# .environmentVariables.CUDA_VISIBLE_DEVICES = the 3090 UUID, NixOS-side);
# bonsai2 → /run/egpu/bonsai.env, rewritten by egpu-adopt/egpu-release on
# dock transitions (3090 docked, 3060 fallback undocked). The swap only
# stops/starts units; it does not touch pins.
{
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      environment.systemPackages = let
        llamacpp-prism-up = pkgs.writeShellScriptBin "llamacpp-prism-up" ''
          set -eu
          sysd=${config.systemd.package}/bin/systemctl
          $sysd stop ollama.service 2>/dev/null || true
          $sysd start bonsai2.service
          echo "bonsai2 (prism llama-server) up on the 3090; ollama stopped"
        '';

        llamacpp-prism-down = pkgs.writeShellScriptBin "llamacpp-prism-down" ''
          set -eu
          sysd=${config.systemd.package}/bin/systemctl
          $sysd stop bonsai2.service 2>/dev/null || true
          $sysd start ollama.service
          echo "ollama up on the 3090; bonsai2 stopped"
        '';
      in [
        llamacpp-prism-up
        llamacpp-prism-down
      ];
    };
  };
}
