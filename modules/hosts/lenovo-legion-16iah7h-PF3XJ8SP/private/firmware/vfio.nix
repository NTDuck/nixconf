{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
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
