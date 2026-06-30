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
        experimental-features = ["nix-command" "flakes" "pipe-operators"];
        trusted-users = ["@wheel"];
      };

      security.sudo = {
        extraRules = [
          {
            users = ["ayin"];
            commands = [
              {
                command = "/run/current-system/specialisation/light-mode/activate";
                options = ["NOPASSWD"];
              }
              {
                command = "/nix/var/nix/profiles/system/bin/switch-to-configuration";
                options = ["NOPASSWD"];
              }
            ];
          }
        ];

        extraConfig = ''
          Defaults timestamp_timeout=-1
          Defaults timestamp_type=tty
        '';
      };
    };
  };
}
