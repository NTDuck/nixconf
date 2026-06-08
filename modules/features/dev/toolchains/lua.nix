{
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.lua-language-server
    ];
  };
}