{den, ...}: {
  den.aspects.dev.toolchains.protobuf = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.protobuf
        pkgs.unstable.protobuf-language-server
      ];
    };
  };
}
