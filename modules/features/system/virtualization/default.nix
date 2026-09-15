{den, ...}: {
  den.aspects.system.virtualization = {
    includes = [
      den.aspects.system.virtualization.docker
      den.aspects.system.virtualization.kubernetes
      den.aspects.system.virtualization.podman
      den.aspects.system.virtualization.qemu
      den.aspects.system.virtualization.vmware
      den.aspects.system.virtualization.waydroid
    ];
  };
}
