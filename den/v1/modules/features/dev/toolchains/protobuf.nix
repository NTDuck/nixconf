{
  den.aspects.dev-toolchains = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.protobuf
        pkgs.unstable.protobuf-language-server
      ];
    };
  };
}
