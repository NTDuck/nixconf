{den, ...}: {
  den.aspects.dev.toolchains.c-cpp = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.clang-tools
        pkgs.unstable.xmake
        pkgs.unstable.cmake-language-server
        pkgs.unstable.nim

        pkgs.unstable.cmake
        pkgs.unstable.gcc
        # pkgs.unstable.mingw-w64
        pkgs.unstable.llvm
      ];
    };
  };
}
