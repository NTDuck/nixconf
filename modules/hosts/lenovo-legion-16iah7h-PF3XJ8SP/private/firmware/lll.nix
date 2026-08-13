{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.lenovo-legion
      ];
    };
  };
}
