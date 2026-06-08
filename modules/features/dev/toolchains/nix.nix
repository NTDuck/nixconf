{
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.nil
      pkgs.unstable.nixd
    ];
  };
}