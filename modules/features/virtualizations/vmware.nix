{den, ...}: {
  den.aspects.virtualization.vmware = {
    nixos = {pkgs, ...}: {
      virtualisation.vmware.host = {
        enable = true;
        package = pkgs.unstable.vmware-workstation;
      };
    };
  };
}
