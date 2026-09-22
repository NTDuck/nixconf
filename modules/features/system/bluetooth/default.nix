{den, ...}: {
  den.aspects.system.bluetooth = {
    includes = [
      den.aspects.system.bluetooth.bluetuith
    ];

    nixos = {pkgs, ...}: {
      hardware.bluetooth = {
        enable = true;
        package = pkgs.unstable.bluez;

        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
    };

    # bluez 5 rejects D-Bus method calls (StartDiscovery, SetDiscoveryFilter,
    # ConnectDevice) from users outside the `bluetooth` group. bluetuith's
    # adapter list populated, but scans returned nothing because calls were
    # denied silently (2026-09-22, DELL user report).
    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["bluetooth"];
    };
  };
}
