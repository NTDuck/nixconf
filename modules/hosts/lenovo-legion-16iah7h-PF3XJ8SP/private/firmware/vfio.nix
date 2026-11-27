# VFIO GPU passthrough for the internal RTX 3060 Mobile — DISABLED.
#
# DISABLED 2026-11-27 (same day it shipped): black-screened generations
# 292/293 (commit 3bdb262) on every boot (journal boots -6..-1). The
# module's prerequisite — "BIOS Graphics Mode must be Dynamic/Hybrid so
# the Intel iGPU drives eDP-1" — is NOT met on this machine: it runs in
# BIOS Discrete mode (lspci shows no 00:02.0 Intel iGPU at all), so the
# internal panel (eDP-1) is wired to the RTX 3060 Mobile itself.
# Forensics (boot -3, 2026-11-27 19:53): vfio-pci binds 01:00.0 in
# initrd ("vgaarb: deactivate vga console") → NVRM "GPU 0000:01:00.0 is
# already bound to vfio-pci", "No NVIDIA devices probed" → nvidia-drm
# only attaches to the headless eGPU 06:00.0 ("Cannot find any crtc or
# sizes") → greetd starts mango with no connected DRM output → black
# screen; system is actually up (SSH/TTY work), user power-cycles.
#
# RE-ENABLE only after: (1) BIOS Graphics Mode → Dynamic/Hybrid so the
# iGPU exists and owns eDP-1, (2) i915/nvidia PRIME primary-GPU setup
# for the mango session, (3) re-check that gpu-unlock's stage-1 FLR +
# vfio-pci initrd binding don't race (see nixconf-gpu-unlock skills).
# Then flip `lib.mkIf false` to `lib.mkIf true`.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }:
      lib.mkIf false {
        # VFIO GPU passthrough for the internal RTX 3060 Mobile (IOMMU group 15):
        #   01:00.0 VGA   [10de:2560] GA106M [GeForce RTX 3060 Mobile / Max-Q]
        #   01:00.1 Audio [10de:228e] GA106 High Definition Audio Controller
        #
        # Prerequisite: BIOS Graphics Mode must be set to Dynamic/Hybrid Graphics
        # so the Intel iGPU drives the internal display (eDP-1) and the RTX 3090
        # eGPU remains available on the Linux host for inference.
        boot.kernelParams = [
          "intel_iommu=on"
          "iommu=pt"
          "vfio-pci.ids=10de:2560,10de:228e"
        ];

        # Bind vfio-pci in stage 1 before nvidia loads in stage 2 (nvidia.nix
        # deliberately defers nvidia to stage 2).
        boot.initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
        ];

        # Looking Glass (kvmfr zero-copy DMABUF shared memory).
        # 64 MiB covers 2560x1600 @ 32bpp RGBA8 (~32.8 MiB double-buffered).
        boot.extraModulePackages = [config.boot.kernelPackages.kvmfr];
        boot.kernelModules = ["kvmfr"];
        boot.extraModprobeConfig = ''
          options kvmfr static_size_mb=64
        '';

        # Allow both the desktop user (looking-glass-client) and libvirt's QEMU
        # process (qemu-libvirtd) to access /dev/kvmfr0.
        services.udev.extraRules = ''
          SUBSYSTEM=="kvmfr", OWNER="ayin", GROUP="qemu-libvirtd", MODE="0660"
        '';

        virtualisation.libvirtd.qemu.verbatimConfig = ''
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/kvmfr0"
          ]
        '';

        environment.systemPackages = [
          pkgs.unstable.looking-glass-client
        ];
      };
  };
}
