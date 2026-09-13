{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      # 1. THE SLOW-TOK/S BUG (2026-09-12, boot -1): nvidia-smi -L listed
      #    the 3090 (NVML adopts hotplugged GPUs fine) while its NVRM bind
      #    had actually failed ("objClInitPcieChipset: Unable to get PCI
      #    port handles"). NVML is not proof of compute health. egpu-adopt
      #    then flipped the inference daemon (now ollama, then llama-cpp) to
      #    the dead 3090; CUDA init fails there
      #    and ggml silently falls back to CPU: 0.2 tok/s, 0% GPU, 33 GB
      #    streamed off NVMe for a 16.3 GB GGUF. Gate the tier flip on a
      #    REAL CUDA probe (llama-server --list-devices, same stack as
      #    inference): the card must appear AND report sane free VRAM.
      # 2. First NVRM bind after a USB4 link train can fail with
      #    "objClInitPcieChipset: Unable to get PCI port handles". In
      #    that state the adopter stays on the laptop 3060; recovery is
      #    a reboot (PCI surgery deadlocks nvidia_modeset, see below).
      # 3. nvidia-persistenced enumerated GPUs at its own startup and never
      #    adopts hotplugged devices, so nvidia-smi/NVML hide the 3090 until
      #    the daemon restarts.
      # 4. The original udev rules matched only ACTION=="add". With the dock
      #    attached at power-on, boltd re-authorizes ("changed", not "add")
      #    and the tunneled PCI device appears before this generation's rule
      #    is loaded — the uevent is never replayed, egpu-adopt never runs,
      #    /dev/nvidia1 never appears, and CUDA/Vulkan/DXVK see only the
      #    3060 + llvmpipe (seen 2026-09-12 boot d2a56796). ACTION!=remove
      #    matches coldplug replay and every rebind; a multi-user.target
      #    boot trigger covers the pre-udevd window outright.
      # CUDA compute probe. nvidia-smi -L is NOT sufficient: NVML lists a
      # hotplugged GPU even when its NVRM bind failed (objClInitPcieChipset),
      # which is exactly how the inference daemon (now ollama, then
      # llama-cpp) got pinned to a dead 3090 and ran on
      # CPU at 0.2 tok/s (2026-09-12 boot -1). llama-server --list-devices
      # exercises the full CUDA stack — the same one inference uses — and
      # prints one line per healthy device:
      #   "  CUDA0: NVIDIA GeForce RTX 3090 (24576 MiB, 23000 MiB free)"
      # A card whose bind failed appears as "(none)"; a card wedged by a
      # stuck context reports 0 MiB free.
      # llama-cpp is now CLI-only; its llama-server binary is reused purely
      # as a CUDA health probe (--list-devices); the serving daemon is ollama.
      llamaServer = "${pkgs.unstable.llama-cpp.override {cudaSupport = true;}}/bin/llama-server";
      # Bounded: CUDA init can block for minutes while nvidia-persistenced
      # brings a freshly-tunneled GPU up (2026-09-13 boot: the adopter's
      # llama-server --list-devices hung 2min and its 120s TimeoutStartSec
      # stalled multi-user.target → graphical at 2min; llama-cpp and the
      # local omp provider only came up after it). Hard timeout keeps the
      # probe from ever exceeding ~15s.
      cudaProbe = pkgs.writeShellScriptBin "egpu-cuda-probe" ''
        set -eu
        if out=$(timeout 15 ${llamaServer} --list-devices 2>/dev/null); then
          printf '%s\n' "$out" | grep -Eq 'RTX 3090 \([0-9]+ MiB, [1-9][0-9]{2,} MiB free\)'
        else
          exit 1
        fi
      '';
      egpu-adopt = pkgs.writeShellScriptBin "egpu-adopt" ''
        set -eu
        sysd=${config.systemd.package}/bin/systemctl
        pin="CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"      # 3090 eGPU
        fallback="CUDA_VISIBLE_DEVICES=GPU-a81782bc-e6d4-e015-445a-d413a0e94529" # 3060 laptop

        mkdir -p /run/egpu
        # Seed once; never clobber a pin a transition already wrote.
        [ -s /run/egpu/ollama.env ] || echo "$fallback" > /run/egpu/ollama.env
        current=$(cat /run/egpu/ollama.env)
        # Rewrite the pin and restart the daemon ONLY on an actual change:
        # udev fires egpu-adopt on every USB4 rebind, and an unconditional
        # restart would evict a resident 16 GB model for nothing.
        tier() {
          [ "$current" = "$1" ] && return 1
          echo "$1" > /run/egpu/ollama.env
          $sysd try-restart ollama.service 2>/dev/null || true
          return 0
        }

        # Dock-less boot (no tunneled GPU): tmpfiles already seeded the
        # fallback pin; nothing to adopt.
        [ -e /sys/bus/pci/devices/0000:06:00.0 ] || exit 0

        # Healthy dock: flip ollama to the 3090. Gated on the CUDA probe,
        # not nvidia-smi -L (see probe comment above).
        if ${cudaProbe}/bin/egpu-cuda-probe; then
          if tier "$pin"; then
            echo "egpu-adopt: 3090 CUDA-healthy, ollama tiered to eGPU" >&2
          else
            echo "egpu-adopt: 3090 CUDA-healthy, ollama already tiered" >&2
          fi
          exit 0
        fi
        # NVML may not see the card yet (persistenced enumerates at startup).
        # Restart it BEFORE probing, then retry with a bounded budget:
        # 6 x (15s probe + 2s sleep) ~= 102s worst case, safely inside the
        # unit's 120s TimeoutStartSec. (Previously 10 unbounded probes could
        # hang for the full timeout and stall the boot transaction.)
        $sysd stop nvidia-persistenced.service 2>/dev/null || true
        $sysd start nvidia-persistenced.service 2>/dev/null || true
        for _ in $(seq 1 6); do
          ${cudaProbe}/bin/egpu-cuda-probe && break
          sleep 2
        done

        if ${cudaProbe}/bin/egpu-cuda-probe; then
          if tier "$pin"; then
            echo "egpu-adopt: 3090 CUDA-healthy after persistenced restart, tiered" >&2
          else
            echo "egpu-adopt: 3090 CUDA-healthy after persistenced restart, already tiered" >&2
          fi
          exit 0
        fi

        # Card present but CUDA-dead (objClInitPcieChipset first-bind
        # failure). DO NOT touch the PCI device: remove/rescan/unbind of a
        # tunneled NVIDIA GPU deadlocks nvidia_modeset in
        # nvEvoDisableVblankSemControl (four hard freezes on 2026-09-12;
        # closed module, hot-unplug unsupported upstream). Stay on the
        # laptop 3060. If the daemon was running on the (now dead) 3090
        # pin, tier() restarts it onto the 3060; boot-time runs are a no-op.
        if tier "$fallback"; then
          echo "egpu-adopt: 3090 present but CUDA-unhealthy (NVRM first-bind failure); ollama reverted to 3060, reboot to recover" >&2
        else
          echo "egpu-adopt: 3090 present but CUDA-unhealthy (NVRM first-bind failure); already on 3060, reboot to recover" >&2
        fi
        exit 1
      '';

      egpu-release = pkgs.writeShellScriptBin "egpu-release" ''
        set -eu
        sysd=${config.systemd.package}/bin/systemctl
        echo "egpu-release: reverting ollama to laptop 3060" >&2
        mkdir -p /run/egpu
        echo "CUDA_VISIBLE_DEVICES=GPU-a81782bc-e6d4-e015-445a-d413a0e94529" > /run/egpu/ollama.env
        $sysd try-restart ollama.service 2>/dev/null || true
        # try-restart, not stop: stopping persistenced on detach left the
        # 3060's BAR1/VA space corrupted on the next enumeration
        # (dmaAllocMapping_GM107 failures, seen 2026-09-13 09:40+).
        $sysd try-restart nvidia-persistenced.service 2>/dev/null || true
        echo "egpu-release: done" >&2
      '';
    in {
      # egpu-cuda-probe exposed for manual health checks: `egpu-cuda-probe && echo 3090 healthy`
      environment.systemPackages = [egpu-adopt egpu-release cudaProbe];

      # Fires when boltd authorizes a new Thunderbolt/USB4 device (the UT3G
      # router 0-1), then again on the tunneled PCI device appearance.
      # ACTION!=remove also matches coldplug replay and boltd's
      # "authorized -> authorized" change events, which the old
      # ACTION=="add" rules missed when the dock was attached at power-on.
      services.udev.extraRules = ''
        # Thunderbolt router (boltctl authorizes -> kernel creates the router)
        ACTION!="remove", SUBSYSTEM=="thunderbolt", ATTRS{device_name}=="UT4G", TAG+="systemd", ENV{SYSTEMD_WANTS}="egpu-adopt.service"
        # Tunneled NVIDIA GPU appearance (belt & braces if bolt already stored)
        ACTION!="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", ENV{PCI_SLOT_NAME}=="0000:06:00.0", TAG+="systemd", ENV{SYSTEMD_WANTS}="egpu-adopt.service"
        # Dock detach: revert llama tiering before the tunnel is gone
        ACTION=="remove", SUBSYSTEM=="thunderbolt", ATTRS{device_name}=="UT4G", TAG+="systemd", ENV{SYSTEMD_WANTS}="egpu-release.service"
      '';

      # Non-blocking boot: a oneshot WantedBy multi-user.target with
      # Before=ollama.service pulled the whole boot transaction for up to
      # 2min (TimeoutStartSec) while the CUDA probe raced persistenced —
      # ollama, the local omp provider and graphical.target all waited
      # behind it (2026-09-13 boot: graphical @2min2s). A timer unit is
      # never part of a target transaction: the adopter runs 15s after
      # boot in the background, udev rules still catch dock events, and
      # ollama starts against the tmpfiles-seeded 3060 pin either way
      # (egpu-adopt flips it to the 3090 once the probe passes).
      systemd.timers.egpu-adopt = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "15";
          Unit = "egpu-adopt.service";
        };
      };

      systemd.services.egpu-adopt = {
        description = "NixOS eGPU adopter: CUDA-health gate and ollama tier flip";
        after = ["bolt.service" "nvidia-persistenced.service"];
        wants = ["bolt.service"];
        # Boot trigger: covers the window where the tunneled GPU appears
        # before udev rules are loaded (no uevent is replayed into a rule
        # that wasn't loaded yet). Dock-less boots seed-and-exit in the
        # script itself.
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${egpu-adopt}/bin/egpu-adopt";
          # Tunnel bring-up races bolt authorization; bounded probes keep
          # the run well inside this budget.
          TimeoutStartSec = "120";
        };
      };
      systemd.services.egpu-release = {
        description = "NixOS eGPU releaser: revert ollama tiering on dock detach";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${egpu-release}/bin/egpu-release";
          TimeoutStartSec = "60";
        };
      };
    };
  };
}
