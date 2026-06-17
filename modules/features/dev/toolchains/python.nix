{den, ...}: {
  den.aspects.python = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.python3
        pkgs.unstable.python3Packages.pip
        pkgs.unstable.python3Packages.virtualenv
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.poetry = {
        enable = true;
        package = pkgs.unstable.poetry;
      };

      programs.uv = {
        enable = true;
        package = pkgs.unstable.uv;
      };
    };
  };
}
