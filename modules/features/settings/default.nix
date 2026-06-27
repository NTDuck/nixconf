{den, ...}: {
  den.aspects.settings = {
    includes = [
      den.aspects.settings.hardware
      den.aspects.settings.i18n
      den.aspects.settings.networking
      den.aspects.settings.time
    ];

    nixos = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["@wheel"];
      };

      security.sudo.extraConfig = "Defaults timestamp_timeout=-1\nDefaults timestamp_type=tty";
    };
  };
}
