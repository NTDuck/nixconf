{den, ...}: {
  den.aspects.ripgrep = {
    home-manager = {pkgs, ...}: {
      programs.ripgrep = {
        enable = true;
        package = pkgs.unstable.ripgrep;
      };
    };
  };
}
