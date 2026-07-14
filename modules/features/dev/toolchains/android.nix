{den, ...}: {
  den.aspects.dev.toolchains.android = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.android-tools
      ];
    };
  };
}
