{ den, inputs, ... }: {
  den.aspects."pear-desktop".nixos = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.unstable.pear-desktop
    ];
  };
}
