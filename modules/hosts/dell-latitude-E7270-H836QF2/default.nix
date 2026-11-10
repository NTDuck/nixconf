{
  den,
  inputs,
  lib,
  ...
}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      # DELL browser (2026-09-24): firefox replaces falkon (parity with legion).
      den.aspects.apps.browsers.firefox
      den.aspects.apps.btop
      den.aspects.apps.p7zip
      den.aspects.apps.ripgrep
      den.aspects.apps.tmux
      den.aspects.apps.zoxide
      den.aspects.apps.pciutils
      den.aspects.apps.jq
      den.aspects.apps.file-managers.pcmanfm
      den.aspects.apps.file-managers.tfm
      den.aspects.remote-desktop.moonlight
      den.aspects.system.network.tailscale
      den.aspects.apps.fastfetch
      den.aspects.apps.gemini-web2api-go
      den.aspects.apps.gnirehtet
      # DELL terminal stack (2026-09-25): st (suckless, X11 — sed/python
      # patched with the stylix palette; reinstated after one day on
      # urxvt).
      den.aspects.apps.terminals.st
      den.aspects.apps.editors.obsidian
      den.aspects.apps.editors.openidea
      den.aspects.apps.editors.zed-editor
      den.aspects.apps.editors.helix
      # Office suite (2026-09-27 user request): same aspect legion uses.
      den.aspects.apps.office.libreoffice
      # Rust Office suite (2026-11-07 user request): WordCraft, GridCraft, DeckCraft
      den.aspects.apps.office.wordcraft
      den.aspects.apps.office.gridcraft
      den.aspects.apps.office.deckcraft
      # Discord client via Vesktop (2026-11-03 user request): parity with legion.
      den.aspects.apps.messaging.discord
      # omp + ninfer-over-tailscale (models.yml points at legion).
      den.aspects.dev.agentics.harnesses.codev
      # learnharness un-included (2026-11-10 user request).
      den.aspects.dev.agentics.harnesses.oh-my-pi
      # CodeGraph CLI (repo indexer used by the coding agents).
      den.aspects.dev.agentics.codegraph
      den.aspects.dev.agentics.cliproxyapi
      den.aspects.dev.agentics.ctx7
      den.aspects.dev.agentics.open-code-review
      den.aspects.dev.agentics.openspec
      den.aspects.dev.envs.mise
      den.aspects.apps.sql.tabularis
      den.aspects.dev.toolchains.java-kotlin
      den.aspects.dev.toolchains.javascript-typescript
      den.aspects.dev.toolchains.nix
      den.aspects.dev.toolchains.rust
      den.aspects.dev.postman
      den.aspects.dev.gits.git
      den.aspects.dev.gits.gh
      den.aspects.dev.gits.glab
      den.aspects.dev.gits.prek
      den.aspects.dev.gitlab-runner
      den.aspects.system.bluetooth
      den.aspects.system.boot.systemd
      den.aspects.system.network.cloudflare-warp
      den.aspects.system.network.nftables
      den.aspects.system.network.resolved
      den.aspects.system.network.ssh
      den.aspects.system.nix
      den.aspects.system.nix.nh
      den.aspects.system.nix.nix-ld
      den.aspects.system.nix.nur
      den.aspects.system.power.power-profiles-daemon
      den.aspects.system.power.upower
      den.aspects.system.secrets.agenix
      den.aspects.system.settings
      den.aspects.system.storage.udisks2
      den.aspects.system.swap.zram
      # spectrwm (X11) — reinstated 2026-09-24 after one day on dwm.
      # The two freeze boots are diagnosed as spectrwm's libswmhack
      # spawn path (LD_PRELOAD injection into every program[] child),
      # fixed with spawn_flags = "nospawnws" in the spectrwm aspect.
      # The spectrwm aspect pulls in its own session furniture
      # (clipmenu, fcitx5, dmenu, dunst, i3lock/xss-lock, portals.xdg)
      # so the host doesn't list them individually.
      den.aspects.desktop.compositors.spectrwm
      # keyd removed (2026-09-24): the X11/spectrwm session needs no
      # key-level remap; repeat rate/delay are set at the X server level
      # (-ardelay/-arinterval in the session wrapper below) to match
      # legion's mango settings (150 ms / 50 cps).
      den.aspects.desktop.auth.gnome-keyring
      # Always-on session (logind lid/suspend keys ignored; sleep
      # targets force-disabled). The idle/lock chain is handled by the
      # i3lock aspect (manual W-Ctrl-l + suspend lock; the X screensaver
      # timer and DPMS are disabled in the dwm session wrapper per the
      # 2026-09-21 "never dim/sleep when idle" request).
      den.aspects.desktop.auth.always-on
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.shells.prompts.powerlevel10k
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      (den.aspects.desktop.greeters.tuigreet {
        session = _config: "dell-latitude-E7270-H836QF2-x11-session";
      })
    ];
  };
}
