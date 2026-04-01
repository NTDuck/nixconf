{ pkgs, ... }:

{
  environment.systemPackages = [
    # Nix
    pkgs.unstable.nil
    pkgs.unstable.nixd

    # Rust
    # TODO Install https://github.com/oxalica/rust-overlay
    pkgs.unstable.rustup

    pkgs.unstable.cargo
    pkgs.unstable.rustc
    pkgs.unstable.rustfmt
    pkgs.unstable.clippy
    pkgs.unstable.rust-analyzer

    # Python
    pkgs.unstable.python3
    pkgs.unstable.python3Packages.pip
    pkgs.unstable.python3Packages.virtualenv

    # Kotlin - Jetpack Compose
    pkgs.unstable.android-studio

    # Java - Spring Boot
    pkgs.unstable.jdk21

    pkgs.unstable.maven
    pkgs.unstable.gradle

    pkgs.unstable.spring-boot-cli

    pkgs.unstable.jetbrains.idea-community
  ];
}
