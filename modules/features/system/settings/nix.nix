{den, ...}: {
  den.aspects.system-nix = {
    nixos = {
      nix.settings.trusted-users = ["@wheel"];
      nix.settings.experimental-features = ["nix-command" "flakes"];
    };
  };
}
