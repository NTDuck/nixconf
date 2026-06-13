{
  den,
  inputs,
  ...
}: {
  den.aspects.cava = {
    homeManager = {pkgs, ...}: {
      programs.cava = {
        enable = true;
        package = pkgs.unstable.cava;
      };
    };
  };
}
