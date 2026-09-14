{den, ...}: {
  den.aspects.dev.api.dbeaver = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        # `dbeaver` (source build) was dropped from nixpkgs; the prebuilt
        # `dbeaver-bin` is the maintained derivation (26.2.0, asl20).
        pkgs.unstable.dbeaver-bin
      ];
    };
  };
}
