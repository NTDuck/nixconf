# HP always-on lid-closed worker policy (2026-11-01): ignore lid and
# power triggers, and disable sleep/suspend/hibernate targets
# completely. Nothing here decides sleep state; the headless box stays
# reachable for distributed builds regardless of lid position.
{
  lib,
  ...
}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
        IdleAction = "ignore";
      };

      systemd.targets.sleep.enable = lib.mkForce false;
      systemd.targets.suspend.enable = lib.mkForce false;
      systemd.targets.hibernate.enable = lib.mkForce false;
      systemd.targets.hybrid-sleep.enable = lib.mkForce false;
    };
  };
}
