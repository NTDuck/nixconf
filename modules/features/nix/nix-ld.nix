{den, ...}: {
  den.aspects.nix-ld = {
    home-manager = {pkgs, ...}: {
      programs.nix-ld = {
        enable = true;
        package = pkgs.unstable.nix-ld;
      };
    };
  };
}
