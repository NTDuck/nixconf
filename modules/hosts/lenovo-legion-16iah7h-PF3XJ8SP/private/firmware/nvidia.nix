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

      # initrd modules so the display hands over without a mode reset.
      boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
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
        # tiering and ollama VRAM residency live.
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
