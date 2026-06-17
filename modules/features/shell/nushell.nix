{den, ...}: {
  den.aspects.nushell = {
    homeManager = {pkgs, ...}: {
      programs.nushell.enable = true;
      programs.nushell.package = pkgs.unstable.nushell;
    };
  };
}
