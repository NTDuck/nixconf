{ den, inputs, ... }: {
  den.aspects.alejandra = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.alejandra
      ];
    };
  };
}
