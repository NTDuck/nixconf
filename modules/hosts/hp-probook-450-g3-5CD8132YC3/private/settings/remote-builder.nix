# HP distributed-build remote worker access (2026-11-08): legion/dell's
# nix-daemons SSH here as ayin for `nix-store --serve`. ayin is
# already trusted via system.settings (`trusted-users = @wheel`)
# and owns the wheel sudo rule, so no dedicated builder user is
# needed. Key bootstrapped out-of-band (password copy), now
# pinned declaratively so it survives reinstalls.
{
  ...
}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {
      users.users.ayin.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8xCluYgGb8Zn8LEa+5EnMaqCw1hHV9nNmwdJbDAB1X ayin@lenovo-legion-16iah7h-PF3XJ8SP"
      ];

      # NOPASSWD for ayin: `nixos-rebuild --target-host ... --use-remote-sudo`
      # runs sudo non-interactively over SSH (no tty to answer). Also
      # required because HP's generated sudoers lacks the stock
      # `#includedir /etc/sudoers.d` line — a sudoers.d drop-in was
      # silently ignored (found 2026-11-08); extraRules lands in the
      # generated /etc/sudoers directly.
      security.sudo.extraRules = [
        {
          users = ["ayin"];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
