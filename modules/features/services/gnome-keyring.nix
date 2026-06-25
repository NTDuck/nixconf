{den, ...}: {
  den.aspects.services.gnome-keyring = {
    includes = [
      den.aspects.services.dconf
    ];

    nixos = {
      security.pam.services = let
        gnome-keyring-enabled = den.aspects.services.gnome-keyring.enable or false;
        services = builtins.attrNames (den.config.security.pam.services or {});
      in
        builtins.listToAttrs (map (service: {
            name = service;
            value = {
              enableGnomeKeyring = gnome-keyring-enabled;
            };
          })
          services);
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
