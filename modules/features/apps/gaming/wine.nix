{den, ...}: {
  den.aspects.apps.gaming.wine = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.wine-wayland
        pkgs.unstable.winetricks
        pkgs.unstable.wineWow64Packages.stableFull
      ];
    };
  };
}
