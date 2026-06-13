{
  den,
  inputs,
  ...
}: {
  den.aspects.bluetuith = {
    homeManager = {pkgs, ...}: {
      programs.bluetuith = {
        enable = true;
        package = pkgs.unstable.bluetuith;
      };
    };
  };
}
