{
  den,
  ...
}: {
  den.aspects.apps.lemonhunt = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        (pkgs.callPackage ./package.nix {})
      ];
    };
  };
}
