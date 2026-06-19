{den, ...}: {
  den.aspects.lua = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lua-language-server
      ];
    };
  };
}
