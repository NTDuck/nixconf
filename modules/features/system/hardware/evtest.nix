{den, ...}: {
  den.aspects.system.hardware.evtest = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.evtest
      ];
    };

    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["input"];
    };
  };
}
