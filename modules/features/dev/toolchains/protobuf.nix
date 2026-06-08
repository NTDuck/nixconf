      {
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.protobuf
      pkgs.unstable.protobuf-language-server
    ];
  };
}