{
  den,
  inputs,
  ...
}: {
  den.aspects.rust = {
    nixos = {pkgs, ...}: {
      nixpkgs.overlays = [
        inputs.rust-overlay.overlays.default
      ];

      environment.systemPackages = [
        (pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src" "rust-analyzer"];
        })

        pkgs.unstable.cargo-nextest
        pkgs.unstable.cargo-binstall

        pkgs.unstable.gcc
        pkgs.unstable.pkg-config
        pkgs.unstable.openssl

        pkgs.unstable.taplo # .toml
      ];
    };
  };
}
