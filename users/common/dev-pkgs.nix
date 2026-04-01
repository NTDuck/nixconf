{ lib, pkgs, ... }:

{
  home.packages = [
    # Nix
    pkgs.unstable.nil
    pkgs.unstable.nixd

    # Rust
    # TODO Install https://github.com/oxalica/rust-overlay
    pkgs.unstable.rustup

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

    pkgs.unstable.jetbrains.idea-oss
    # pkgs.unstable.jetbrains.idea-community
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.unstable.jdk21.home}";
  };

  home.activation.autorun-rustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${pkgs.unstable.rustup}/bin:$PATH"

    $DRY_RUN_CMD rustup update stable nightly

    if ! rustup show active-toolchain &> /dev/null; then
      $DRY_RUN_CMD rustup default stable
    fi
  '';
}
