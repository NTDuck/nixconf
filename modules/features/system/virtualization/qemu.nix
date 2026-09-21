# TODO Slop, check this guy
{den, ...}: {
  den.aspects.system.virtualization.qemu = {
    nixos = {pkgs, ...}: {
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
        };

        # Enable SPICE USB redirection so guests can use attached peripherals.
        spiceUSBRedirection.enable = true;
      };

      # NAT network for guests (virbr0 DHCP/DNS). libvirt ships default.xml
      # but NixOS 26.05's libvirtd module has no `networks` option to enable
      # or autostart it, so net-start/autostart it after libvirtd-config
      # copies the XML into /var/lib (idempotent; virsh talks to the daemon).
      systemd.services.libvirtd-network-default = {
        after = ["libvirtd-config.service" "libvirtd.service"];
        wantedBy = ["multi-user.target"];
        wants = ["libvirtd.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = [
            "${pkgs.libvirt}/bin/virsh --connect qemu:///system net-start default"
            "${pkgs.libvirt}/bin/virsh --connect qemu:///system net-autostart default"
          ];
          # Network already active/autostarted → nonzero exit; harmless.
          SuccessExitStatus = [1];
        };
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

      # virt-manager probes FHS paths (/usr/bin/qemu-system-*) to autodetect
      # the default URI; on NixOS none exist, so it fails with "Could not
      # detect a default hypervisor" even though libvirtd serves qemu:///system
      # (virsh confirms). Pin the connection instead of relying on the probe.
      environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";

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
