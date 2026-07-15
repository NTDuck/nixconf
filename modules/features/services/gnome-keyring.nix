{den, ...}: {
  den.aspects.services.gnome-keyring = {
    includes = [
      den.aspects.services.dconf
    ];

    nixos = {
      services.gnome.gnome-keyring.enable = true;

      security.pam.services = {
        login.enableGnomeKeyring = true;
        tuigreet.enableGnomeKeyring = true;
      };
    };

    homeManager = {pkgs, ...}: {
      services.gnome-keyring = {
        enable = true;
        package = pkgs.unstable.gnome-keyring;
      };

      # home.sessionVariables = {
      #   SSH_AUTH_SOCK = "/run/user/$UID/keyring/ssh";
      #   GNOME_KEYRING_CONTROL = "/run/user/$UID/keyring";
      # };
    };
  };
}
