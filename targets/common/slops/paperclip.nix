{inputs, ...}: {
  imports = [
    inputs.paperclip.nixosModules.paperclip
  ];

  services.paperclip = {
    enable = true;

    database.external.enable = true;

    # environmentFile = "/var/lib/secrets/paperclip.env";

    settings = {
      server = {
        port = 8080;
      };
    };
  };

  systemd.services.paperclip.serviceConfig.EnvironmentFile = "/var/lib/secrets/paperclip.env";

  # sudo mkdir -p /var/lib/secrets
  # sudo touch /var/lib/secrets/paperclip.env
  # sudo chmod 600 /var/lib/secrets/paperclip.env

  # PAPERCLIP_DATABASE_EXTERNAL_URL="postgresql://user:password@localhost:5432/paperclip"
}
