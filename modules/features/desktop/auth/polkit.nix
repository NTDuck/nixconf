{den, ...}: {
  den.aspects.desktop.auth.polkit = {
    nixos = {pkgs, ...}: {
      security.polkit = {
        enable = true;
        package = pkgs.unstable.polkit;
      };
    };
  };
}
