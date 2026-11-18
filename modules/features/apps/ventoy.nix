# ventoy (2026-11-18 user request): multi-boot USB toolkit.
# Impression (apps.rufus) writes ISOs verbatim; ventoy installs its own
# bootloader on the stick so multiple ISOs boot from one drive. Requires
# Secure Boot OFF at boot time — systemd-boot host config doesn't enroll it.
{den, ...}: {
  den.aspects.apps.ventoy = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.ventoy-full
      ];
    };
  };
}
