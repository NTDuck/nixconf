{den, ...}: {
  den.aspects.Noctalia-shell = {
    homeManager = {pkgs, ...}: {
      programs.nushell.enable = true;
      programs.nushell.package = pkgs.unstable.nushell;
    };
  };
}
