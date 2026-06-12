{ den, inputs, ... }: {
  den.aspects.protobuf = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.protobuf
        pkgs.unstable.protobuf-language-server
      ];
    };
  };
}
