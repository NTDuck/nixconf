{
  den,
  inputs,
  ...
}: {
  den.aspects.mpv = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.mpv
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.mpv = {
        enable = true;
        package = pkgs.unstable.mpv;
      };
    };
  };
}
