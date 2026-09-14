{den, ...}: {
  den.aspects.system.settings = {
    includes = [
      den.aspects.system.settings.hardware
      den.aspects.system.settings.i18n
      den.aspects.system.settings.networking
      den.aspects.system.settings.time
    ];

    nixos = {
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        # experimental-features = ["nix-command" "flakes" "pipe-operators"];
        trusted-users = ["@wheel"];
      };

      # nix.extraOptions = ''
      #   !include ${config.age.secrets."github-personalaccesstoken".path}
      # '';

      security.sudo.extraConfig = ''
        Defaults timestamp_timeout=-1
        Defaults timestamp_type=tty
      '';
    };
  };
}
