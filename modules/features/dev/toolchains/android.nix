{den, ...}: {
  den.aspects.dev.toolchains.android = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.android-tools
      ];
    };

    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["adbusers"];
    };
  };
}
