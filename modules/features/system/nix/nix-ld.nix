{den, ...}: {
  den.aspects.system.nix.nix-ld = {
    nixos = {pkgs, ...}: {
      programs.nix-ld = {
        enable = true;
        package = pkgs.unstable.nix-ld;
      };
    };
  };
}
