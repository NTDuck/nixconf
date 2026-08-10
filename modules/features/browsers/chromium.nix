{den, ...}: {
  den.aspects.browsers.chromium = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.chromium
      ];
    };

    # homeManager = {pkgs, ...}: {
    #   programs.chromium = {
    #     enable = true;
    #     package = pkgs.unstable.chromium;
    #   };
    # };
  };
}
