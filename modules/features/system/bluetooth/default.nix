{den, ...}: {
  den.aspects.system.bluetooth = {
    includes = [
      den.aspects.system.bluetooth.bluetuith
    ];

    nixos = {pkgs, ...}: {
      # BCM43142A0 (dell's BT adapter) firmware drops ACL packet completion
      # reports while the USB device autosuspends mid-A2DP-stream —
      # wireplumber logs "Missing completion reports for packet ...
      # Bluetooth adapter firmware bug?" (40x in one session, 2026-09-28)
      # and the transport eventually fails outright
      # ("Acquire ... org.bluez.Error.Failed" → audible stutter/
      # fragmentation). btusb's enable_autosuspend=0 keeps the adapter
      # permanently awake so completion reports never go missing.
      boot.kernelParams = ["btusb.enable_autosuspend=0"];

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
