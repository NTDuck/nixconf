{den, ...}: {
  den.aspects.dev.cloud.oracle-cloud-infrastructure = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.oci-cli
      ];
    };
  };
}
