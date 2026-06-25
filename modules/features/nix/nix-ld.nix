{den, ...}: {
  den.aspects.nix-ld = {
    homeManager = {pkgs, ...}: {
      programs.nix-ld = {
        enable = true;
        package = pkgs.unstable.nix-ld;
      };
    };
  };
}
