{den, ...}: {
  den.aspects.dev.oracle-cloud-infrastructure = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.oci-cli
      ];
    };
  };
}
