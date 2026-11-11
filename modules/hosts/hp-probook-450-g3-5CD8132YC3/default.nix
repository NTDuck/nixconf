# HP ProBook 450 G3 headless worker host (2026-11-01):
# Renamed from placeholder xxxx to hardware serial 5CD8132YC3 (scanned via dmidecode).
# No GUI/WM, lid stays closed with battery connected, connects to legion over
# SSH & Tailscale mesh, terminal utilities only.
{den, ...}: {
  den.hosts.x86_64-linux.hp-probook-450-g3-5CD8132YC3 = {
    users.ayin = {};
  };
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    includes = [
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

      # Dev — explicit headless set instead of the den.aspects.dev
      # umbrella (2026-11-10 user request: drop GUI on the headless
      # worker; the umbrella pulled postman, the SQL GUI clients via
      # toolchains.sql, and the learnharness AppImage through its
      # agentics/harnesses chain).
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.agentics.harnesses.codev
      den.aspects.dev.agentics.harnesses.codex
      # cliproxyapi un-included (2026-11-11 user request).
      den.aspects.dev.agentics.codegraph
      den.aspects.dev.agentics.ctx7
      den.aspects.dev.agentics.openspec
      den.aspects.dev.agentics.spec-kit
      den.aspects.dev.envs
      den.aspects.dev.gits
      den.aspects.dev.toolchains.nix
      den.aspects.dev.toolchains.python
      den.aspects.dev.toolchains.rust
      den.aspects.dev.toolchains.sql
      den.aspects.dev.terraform
      den.aspects.dev.gitlab-runner

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
  };
}
