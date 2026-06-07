{inputs, ...}: {
  flake.modules.nixos.gc = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 4d";
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nix-clean" ''
        echo "`sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2`"
        sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +2
        echo "`nix-collect-garbage -d`"
        sudo nix-collect-garbage -d
      '')
    ];
  };
}
