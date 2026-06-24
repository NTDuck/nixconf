{den, ...}: {
  den.aspects.dev.toolchains.lua = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lua-language-server
      ];
    };
  };
}
