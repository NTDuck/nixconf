{
  den,
  inputs,
  ...
}: {
  den.aspects.imv = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.imv
      ];
    };

    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.imv = {
        enable = true;
        package = pkgs.unstable.imv;
      };
    };
  };
}
