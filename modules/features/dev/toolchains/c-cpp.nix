{
  flake.modules.nixos.dev-toolchains = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.unstable.clang-tools
      pkgs.unstable.xmake
      pkgs.unstable.cmake-language-server
      pkgs.unstable.nim
    ];
  };
}
