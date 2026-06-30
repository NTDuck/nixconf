{den, ...}: {
  den.aspects.nix-ld = {
    nixos = {pkgs, ...}: {
      programs.nix-ld = {
        enable = true;
        package = pkgs.unstable.nix-ld;
      };
    };
  };
}
