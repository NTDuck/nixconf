{den, ...}: {
  den.aspects.bluetuith = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.bluetuith
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.bluetuith = {
        enable = true;
        package = pkgs.unstable.bluetuith;
      };
    };
  };
}
