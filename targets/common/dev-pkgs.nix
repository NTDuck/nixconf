{ pkgs, ... }:

{
  environment.systemPackages = [
    # Nix
    pkgs.nil
    pkgs.nixd

    # Rust
    # TODO Install https://github.com/oxalica/rust-overlay
    pkgs.rustup

    pkgs.cargo
    pkgs.rustc
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer

    # Python
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.python3Packages.virtualenv

    # Kotlin - Jetpack Compose
    pkgs.android-studio
  ];
}
