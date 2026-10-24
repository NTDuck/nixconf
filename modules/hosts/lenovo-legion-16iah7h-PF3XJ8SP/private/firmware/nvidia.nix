{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      # The nixos-hardware Legion profile (not included) ships the same
      # johnfanv2 `lenovo-legion-module` that firmware/lll.nix wires up.
      # hardware.nvidia.open was the profile's default; kept explicit.
      hardware.nvidia.open = true;

      hardware.nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        nvidiaPersistenced = true;
        powerManagement.enable = true;
      };

      services.xserver = {
        videoDrivers = ["nvidia"];
      };

      # NOT in the initrd. With gpu-unlock active, a cold boot FLRs the
      # 3090 through the ADT-UT4G TB4 dock; the FLR drops the dock's PCIe
      # link and the tunnel bounces for several seconds (journalctl:
      # "Slot(3): Link Down" 5s after "FLR returned", then thunderbolt
      # disconnect/reconnect loop). nvidia's RM init in stage 1 at that
      # moment wedges the 3090 (NV_ERR_GPU_IS_LOST, nvidia-modeset
      # progress timeouts) and boot hangs on 90s unit timeouts
      # (systemd-backlight@nvidia_0). Loading nvidia only in stage 2
      # reproduces the pre-unlock sequence that cold-boots fine: by the
      # time udev coldplugs stage 2, the tunnel has re-linked.
      # Cost: console handover mode-resets (cosmetic flash) since fbcon
      # starts on simpledrm instead of nvidia-drm.
      # boot.initrd.kernelModules intentionally absent for nvidia*.
      # NMI watchdog: kernel hard-locks (driver spinlock deadlock)
      # self-reboot via the intel_oc_wdt hardware watchdog.
      boot.kernelParams = ["nmi_watchdog=1"];

      # Freeze safety net: driver-deadlock freezes kill the display but
      # SysRq still works — Alt+SysRq+R,E,I,S,U,B (REISUB) recovers
      # without power-cycling. Full sysrq bitmask.
      boot.kernel.sysctl."kernel.sysrq" = 1;

      environment.systemPackages = [
        pkgs.unstable.libva
        pkgs.unstable.libva-utils
        pkgs.unstable.libva-vdpau-driver
        # eGPU verification: enumerate ICDs per-arch, render on the 3090.
        pkgs.vulkan-tools
        # Interactive GPU/process monitor (NVML): watch the 3090 eGPU
        # tiering and ashalliants VRAM residency live.
        pkgs.nvitop
      ];

      # wine on the eGPU: DXVK/VKD3D pick the device by name; wine's WSI
      # goes through Xwayland (X11) so no special Wayland WSI needed. The
      # 32-bit NVIDIA Vulkan/GL stack ships in hardware.graphics
      # extraPackages32 (opengl-driver-32), already enabled host-wide.
      environment.sessionVariables = {
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        LIBVA_DRIVER_NAME = "nvidia";
      };
    };
  };
}
