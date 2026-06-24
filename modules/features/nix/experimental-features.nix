{den, ...}: {
  den.aspects.experimental-features = {
    nixos = {
      nix.settings.trusted-users = ["@wheel"]; # Why is this here?
      nix.settings.experimental-features = ["nix-command" "flakes"];

      security.sudo.extraConfig = "Defaults timestamp_timeout=-1\nDefaults timestamp_type=tty"; # Why is this here?
    };
  };
}
