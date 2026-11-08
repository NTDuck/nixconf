# HP ProBook 450 G3 headless worker host (2026-11-01):
# Renamed from placeholder xxxx to hardware serial 5CD8132YC3 (scanned via dmidecode).
# No GUI/WM, lid stays closed with battery connected, connects to legion over
# SSH & Tailscale mesh, terminal utilities only.
{
  den,
  lib,
  ...
}: {
  den.hosts.x86_64-linux.hp-probook-450-g3-5CD8132YC3 = {
    users.ayin = {};
  };
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    includes = [
      # Always-on lid-closed worker policy: ignore lid and power triggers,
      # and disable sleep/suspend/hibernate targets completely.
      {
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
      }

      # Disable registering the ~ key (scancode 0x29 / KEY_GRAVE):
      # Prevents ghost/stuck key events when the lid is closed or from physical keyboard fault.
      # Mapped to KEY_RESERVED via udev hwdb so the Linux kernel input layer drops events.
      {
        nixos = {
          services.udev.extraHwdb = ''
            # HP ProBook internal AT keyboard (scancode 0x29 -> reserved)
            evdev:atkbd:dmi:*
             KEYBOARD_KEY_29=reserved

            # Generic USB / HID keyboard (usage 0x70035 -> reserved)
            evdev:input:b*v*p*
             KEYBOARD_KEY_70035=reserved
          '';
        };
      }

      # Remote connectivity: SSH server + Tailscale mesh network
      # to connect seamlessly to legion and off-LAN nodes.
      den.aspects.system.network.ssh
      den.aspects.system.network.tailscale
      den.aspects.system.network.resolved

      # Terminal utilities
      den.aspects.apps.btop
      den.aspects.apps.fastfetch
      den.aspects.apps.jq
      den.aspects.apps.p7zip
      den.aspects.apps.pciutils
      den.aspects.apps.ripgrep
      den.aspects.apps.tmux
      den.aspects.apps.zoxide
      den.aspects.apps.editors.helix
      den.aspects.dev.gits.git
      # omp harness (oh-my-pi): config.default.yml + omp alias; the
      # host-private agentics.nix pins models.yml to the local BitNet
      # engine and defines ompl.
      den.aspects.dev.agentics.harnesses.oh-my-pi

      # Shell & prompt
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.shells.prompts.starship

      # System base
      den.aspects.system.boot.systemd
      den.aspects.system.nix
      den.aspects.system.nix.lix
      den.aspects.system.settings
      den.aspects.system.storage.fstrim
      den.aspects.system.swap.zram
    ];

    nixos = {
      # Distributed-build remote worker (2026-11-08): legion/dell's
      # nix-daemons SSH here as ayin for `nix-store --serve`. ayin is
      # already trusted via system.settings (`trusted-users = @wheel`)
      # and owns the wheel sudo rule, so no dedicated builder user is
      # needed. Key bootstrapped out-of-band (password copy), now
      # pinned declaratively so it survives reinstalls.
      users.users.ayin.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8xCluYgGb8Zn8LEa+5EnMaqCw1hHV9nNmwdJbDAB1X ayin@lenovo-legion-16iah7h-PF3XJ8SP"
      ];

      # NOPASSWD for ayin: `nixos-rebuild --target-host ... --use-remote-sudo`
      # runs sudo non-interactively over SSH (no tty to answer). Also
      # required because HP's generated sudoers lacks the stock
      # `#includedir /etc/sudoers.d` line — a sudoers.d drop-in was
      # silently ignored (found 2026-11-08); extraRules lands in the
      # generated /etc/sudoers directly.
      security.sudo.extraRules = [{
        users = ["ayin"];
        commands = [{
          command = "ALL";
          options = ["NOPASSWD"];
        }];
      }];
    };
  };
}
