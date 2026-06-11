{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.clang-tools
        pkgs.unstable.xmake
        pkgs.unstable.cmake-language-server
        pkgs.unstable.nim
      ];
    };
  };
}
