{den, ...}: {
  den.aspects.dev.cloud.google-cloud-sdk = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.google-cloud-sdk
      ];
    };
  };
}
