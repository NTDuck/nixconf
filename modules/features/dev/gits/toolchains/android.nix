{den, ...}: {
  den.aspects.android = {
    nixos = {
      user,
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        pkgs.unstable.android-tools
      ];

      users.users.${user.name}.extraGroups = ["adbusers" "kvm"];
    };
  };
}
