{ lib, pkgs, ... }:

{
  home.packages = [
    # Nix
    pkgs.unstable.nil
    pkgs.unstable.nixd

    # Topiary
    pkgs.unstable.topiary
    pkgs.unstable.nickel

    # Rust
    # TODO Install https://github.com/oxalica/rust-overlay
    pkgs.unstable.rustup
    pkgs.unstable.cargo-binstall

    pkgs.unstable.gcc
    pkgs.unstable.pkg-config
    pkgs.unstable.openssl

    # Lua
    pkgs.unstable.lua-language-server

    # C/C++
    pkgs.unstable.clang-tools
    pkgs.unstable.xmake
    pkgs.unstable.cmake-language-server

    # Python
    pkgs.unstable.python3
    pkgs.unstable.python3Packages.pip
    pkgs.unstable.python3Packages.virtualenv

    # Javascript/Typescript
    pkgs.unstable.deno
    pkgs.unstable.bun

    pkgs.unstable.javascript-typescript-langserver
    pkgs.unstable.tailwindcss-language-server

    # Docker
    pkgs.unstable.docker-language-server
    pkgs.unstable.dockerfile-language-server

    # Svelte
    pkgs.unstable.svelte-language-server

    # Kotlin - Jetpack Compose
    pkgs.unstable.android-studio
    pkgs.unstable.android-tools

    pkgs.unstable.kotlin-language-server

    # Java - Spring Boot
    pkgs.unstable.jdk21

    pkgs.unstable.maven
    pkgs.unstable.gradle

    pkgs.unstable.spring-boot-cli
    pkgs.unstable.jdt-language-server

    pkgs.unstable.jetbrains.idea-oss
    # pkgs.unstable.jetbrains.idea-community
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.unstable.jdk21.home}";
  };

  home.activation.postinstall-rust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "> RUNNING home.activation.postinstall-rust"
    export PATH="${pkgs.unstable.rustup}/bin:${pkgs.unstable.cargo-binstall}/bin:$PATH"

    echo "> RUNNING rustup update stable nightly"
    $DRY_RUN_CMD rustup update stable nightly

    if ! rustup show active-toolchain &> /dev/null; then
      echo "> RUNNING rustup default stable"
      $DRY_RUN_CMD rustup default stable
    fi

    echo "> RUNNING cargo binstall -y cargo-nextest --secure"
    $DRY_RUN_CMD cargo binstall -y cargo-nextest --secure

    echo "> home.activation.postinstall-rust DONE"
  '';
}
