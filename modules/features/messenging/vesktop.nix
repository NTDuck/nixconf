{
  den,
  inputs,
  ...
}: {
  den.aspects.vesktop = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.vesktop
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop;
      };
    };
  };
}
