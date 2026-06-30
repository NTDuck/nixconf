{
  den,
  inputs,
  ...
}: {
  den.aspects.messenging.telegram = {
    nixos = {pkgs, ...}: {
      # https://github.com/ndfined-crp/ayugram-desktop#--manual-binary-cache-setup
      nix.settings = {
        extra-substituters = [
          "https://cache.garnix.io"
          "https://ayugram-desktop.cachix.org"
        ];
        extra-trusted-substituters = [
          "https://cache.garnix.io"
          "https://ayugram-desktop.cachix.org"
        ];
        extra-trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
          "ayugram-desktop.cachix.org:AZ5EqHrJsAKL5YkZYLPEsb1FdD9QlypUwQ0REcJftgA="
        ];
      };

      environment.systemPackages = [
        inputs.ayugram.packages.${pkgs.stdenv.hostPlatform.system}.ayugram-desktop
      ];
    };
  };
}
