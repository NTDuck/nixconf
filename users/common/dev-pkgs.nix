{pkgs, ...}: {
  home.packages = [
    # Nix
    pkgs.unstable.nil
    pkgs.unstable.nixd

    pkgs.unstable.nixpkgs-fmt

    # Topiary
    pkgs.unstable.topiary

    pkgs.unstable.nickel # .ncl
    pkgs.unstable.ts_query_ls # .scm

    # Rust
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = ["rust-src" "rust-analyzer"];
    })

    pkgs.unstable.cargo-nextest
    pkgs.unstable.cargo-binstall

    pkgs.unstable.gcc
    pkgs.unstable.pkg-config
    pkgs.unstable.openssl

    pkgs.unstable.taplo # .toml

    # Lua
    pkgs.unstable.lua-language-server

    # C/C++
    pkgs.unstable.clang-tools
    pkgs.unstable.xmake
    pkgs.unstable.cmake-language-server
    pkgs.unstable.nim

    # Python
    pkgs.unstable.python3
    pkgs.unstable.python3Packages.pip
    pkgs.unstable.python3Packages.virtualenv
    pkgs.unstable.python3Packages.chromadb

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
}
