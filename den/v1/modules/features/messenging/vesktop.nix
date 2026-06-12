{
  den,
  inputs,
  ...
}: {
  den.aspects.vesktop = {
    homeManager = {pkgs, ...}: {
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop;
      };
    };
  };
}
