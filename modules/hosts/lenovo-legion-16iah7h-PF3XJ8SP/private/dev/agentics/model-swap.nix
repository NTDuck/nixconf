# model-swap — arbitrate the 3090 between bonsai2 and ollama.
#
# WHY THIS EXISTS (2026-09-20): both 27B daemons want the 3090 and cannot be
# resident together (bonsai 192K ctx ≈ 19 GiB; ollama 27B q4_K_M + KV ≈ 18
# GiB; card has 24 GiB). The old shared /run/egpu/ollama.env pin made them
# co-resident, which degraded ollama's 27B loads to 34/66 GPU layers @
# 1.6 tok/s (client timeouts → "404/no output"). User decision (2026-09-20,
# ask): swap-helper arbitration — exactly one daemon resident at a time,
# mmap loads make switches fast (bonsai: ~6 s; ollama 27B: ~10-20 s).
#
# GPU pins stay as they are: ollama → 3090 only (services.ollama
# .environmentVariables.CUDA_VISIBLE_DEVICES = "0", NixOS-side); bonsai2 →
# /run/egpu/bonsai.env, rewritten by egpu-adopt/egpu-release on dock
# transitions (3090 docked, 3060 fallback undocked). The swap only stops/
# starts units; it does not touch pins.
{
  den,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      environment.systemPackages = let
        model-swap = pkgs.writeShellScriptBin "model-swap" ''
          set -eu
          sysd=${config.systemd.package}/bin/systemctl
          usage() {
            echo "usage: model-swap bonsai|ollama|game|status" >&2
            echo "  bonsai  - stop ollama, start bonsai2 (3090, 192K ctx)" >&2
            echo "  ollama  - stop bonsai2, start ollama (3090, 27B models)" >&2
            echo "  game    - stop both (free the 3090 for the eGPU game)" >&2
            echo "  status  - show which daemons are active" >&2
            exit 2
          }
          [ $# -eq 1 ] || usage
          case "$1" in
            bonsai)
              $sysd stop ollama.service 2>/dev/null || true
              $sysd start bonsai2.service
              echo "bonsai2 up (3090; ollama stopped)"
              ;;
            ollama)
              $sysd stop bonsai2.service 2>/dev/null || true
              $sysd start ollama.service
              echo "ollama up (3090; bonsai2 stopped)"
              ;;
            game)
              $sysd stop bonsai2.service 2>/dev/null || true
              $sysd stop ollama.service 2>/dev/null || true
              echo "both daemons stopped; 3090 free"
              ;;
            status)
              printf 'ollama : '; $sysd is-active ollama.service
              printf 'bonsai2: '; $sysd is-active bonsai2.service
              nvidia-smi --query-compute-apps=pid,used_memory --format=csv,noheader || true
              ;;
            *) usage ;;
          esac
        '';
      in [
        model-swap
      ];
    };
  };
}
