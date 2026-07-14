{den, ...}: {
  den.aspects.virtualization.qemu = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      # KVM kernel modules are often auto-detected, but you can ensure they are loaded
      boot.kernelModules = ["kvm-amd" "kvm-intel"];

      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.unstable.qemu_kvm;
            # Enable TPM 2.0 support, required for Windows 11 [citation:2]
            swtpm.enable = true;
            # Enable UEFI support with OVMF [citation:2][citation:4]
            # ovmf.enable = true;
            # ovmf.packages = [pkgs.unstable.OVMFFull.fd];
          };

          # networks.default = {
          #   enable = true;
          #   autostart = true;
          # };
        };
        # Enables USB redirection support, which is helpful for peripherals [citation:4]
        spiceUSBRedirection.enable = true;
      };

      # Seems like Legion-specific? This is to connect to internet
      networking.firewall.interfaces.virbr0 = {
        # DNS and DHCP from virtual machines to the host.
        allowedUDPPorts = [
          53
          67
        ];

        # DNS can fall back to TCP.
        allowedTCPPorts = [
          53
        ];
      };

      # Install a graphical interface and necessary tools [citation:2][citation:4]
      environment.systemPackages = [
        pkgs.unstable.virt-manager # Main GUI for managing VMs
        pkgs.unstable.virt-viewer # For connecting to VM consoles
        pkgs.unstable.spice # SPICE protocol support
        pkgs.unstable.spice-gtk
        pkgs.unstable.virtio-win # VirtIO drivers for Windows [citation:2]
        pkgs.unstable.spice-vdagent # SPICE guest tools for Windows [citation:2]
        # qemu is included as a dependency
      ];

      # Allow dconf settings for virt-manager (optional)
      programs.dconf.enable = true;
    };
  };
}
