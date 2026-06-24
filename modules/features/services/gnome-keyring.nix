{den, ...}: {
  den.aspects.services.gnome-keyring = {
    includes = [
      den.aspects.services.dconf
    ];

    homeManager = {pkgs, ...}: {
      services.gnome-keyring = {
        enable = true;
        package = pkgs.unstable.gnome-keyring;
      };
    };
  };
}
