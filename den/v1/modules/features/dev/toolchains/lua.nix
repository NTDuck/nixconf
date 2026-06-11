{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lua-language-server
      ];
    };
  };
}
