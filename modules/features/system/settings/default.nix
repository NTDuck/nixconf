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
