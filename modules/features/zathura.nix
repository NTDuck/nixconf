{den, ...}: {
  den.aspects.zathura = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.zathura
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.zathura = {
        enable = true;
        package = pkgs.unstable.zathura;

        options = {
          selection-clipboard = "clipboard";
          recolor = true;
        };
      };
    };
  };
}
