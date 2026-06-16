{
  den,
  inputs,
  ...
}: {
  den.aspects.cava = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.cava
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
