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
            # Windows 11 guests require TPM 2.0.
            swtpm.enable = true;
            # Keep OVMF nearby for Windows guests, but leave it disabled until
            # a VM definition needs explicit firmware ownership.
            # ovmf.enable = true;
            # ovmf.packages = [pkgs.unstable.OVMFFull.fd];
          };

          # networks.default = {
          #   enable = true;
          #   autostart = true;
          # };
        };
        # Enable SPICE USB redirection so guests can use attached peripherals.
        spiceUSBRedirection.enable = true;
      };

      # libvirt's default NAT network serves DHCP/DNS from virbr0. The firewall
      # must allow those host-side services or guests boot without networking.
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

      # GUI management and Windows guest integration tools.
      environment.systemPackages = [
        pkgs.unstable.virt-manager # Main GUI for managing VMs
        pkgs.unstable.virt-viewer # For connecting to VM consoles
        pkgs.unstable.spice # SPICE protocol support
        pkgs.unstable.spice-gtk
        pkgs.unstable.virtio-win # VirtIO drivers for Windows guests
        pkgs.unstable.spice-vdagent # SPICE guest tools for Windows guests
        # qemu is included as a dependency
      ];

      # Allow dconf settings for virt-manager (optional)
      programs.dconf.enable = true;
    };

    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = [
        "kvm"
        "libvirtd"
      ];
    };
  };
}
