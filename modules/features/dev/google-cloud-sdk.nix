{den, ...}: {
  den.aspects.dev.google-cloud-sdk = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.google-cloud-sdk
      ];
    };
  };
}
