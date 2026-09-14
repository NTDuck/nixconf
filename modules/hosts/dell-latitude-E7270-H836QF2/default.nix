{den, ...}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {};
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.system.power.power-profiles-daemon
      den.aspects.system.power.upower
      den.aspects.system.bluetooth
      den.aspects.system.boot.systemd
      den.aspects.apps.browsers.chromium
      den.aspects.apps.browsers.zen-browser
      (den.aspects.desktop.compositors.mangowm {
        terminal = pkgs: "${pkgs.unstable.ghostty}/bin/ghostty";
      })
      den.aspects.dev
      den.aspects.apps.editors.helix
      den.aspects.apps.editors.zed-editor
      den.aspects.apps.file-managers.nemo
      den.aspects.apps.file-managers.yazi
      den.aspects.apps.gaming.itch
      den.aspects.apps.gaming.mangohud
      den.aspects.apps.gaming.steam
      den.aspects.apps.gaming.wine
      den.aspects.apps.gaming.wlib
      den.aspects.apps.gaming.rpgmakermlinux-cicpoffs
      den.aspects.apps.gaming.roleplaying.risuai
      den.aspects.apps.gaming.roleplaying.sillytavern
      den.aspects.apps.gaming.roleplaying.rp
      (den.aspects.desktop.greeters.tuigreet {
        command = config: "${config.programs.mango.package}/bin/mango";
      })
      # `linux-cachyos-latest-7.1.1` conflicts with `broadcom-sta`
      # den.aspects.system.kernel.cachyos-kernel
      den.aspects.apps.messenging.discord
      den.aspects.apps.messenging.telegram
      den.aspects.apps.messenging.lark-cli
      den.aspects.apps.multimedia.gallery-dl
      den.aspects.apps.multimedia.imv
      den.aspects.apps.multimedia.mpv
      den.aspects.apps.multimedia.obs-studio
      den.aspects.apps.multimedia.yt-dlp
      den.aspects.apps.music.youtube-music
      den.aspects.system.nix
      den.aspects.desktop.panels.noctalia
      # den.aspects.system.nix.lix
      den.aspects.system.nix.nh
      den.aspects.system.nix.nix-ld
      den.aspects.system.nix.nur
      den.aspects.apps.office.pandoc
      den.aspects.apps.office.libreoffice
      den.aspects.apps.office.texlive
      den.aspects.apps.office.zathura
      den.aspects.apps.productivity.mermaid
      den.aspects.apps.productivity.obsidian
      den.aspects.apps.productivity.taskwarrior
      den.aspects.apps.productivity.tomato
      den.aspects.apps.productivity.world-monitor
      den.aspects.system.secrets.agenix
      den.aspects.desktop.clipboard.cliphist
      den.aspects.system.network.cloudflare-warp
      den.aspects.desktop.settings.dconf
      den.aspects.desktop.input.fcitx5
      den.aspects.desktop.auth.gnome-keyring
      den.aspects.desktop.fs.gvfs
      den.aspects.desktop.wayland.kanshi
      den.aspects.desktop.input.keyd
      den.aspects.system.network.nftables
      den.aspects.desktop.audio.pipewire
      den.aspects.desktop.auth.polkit
      den.aspects.system.network.resolved
      den.aspects.system.network.ssh
      den.aspects.system.storage.udisks2
      den.aspects.desktop.portals.xdg
      den.aspects.system.settings
      den.aspects.desktop.shells.prompts.starship
      den.aspects.desktop.shells.zsh
      den.aspects.system.swap.zram
      den.aspects.apps.terminals.ghostty
      den.aspects.desktop.screenshots.flameshot
      den.aspects.desktop.screenshots.gpu-screen-recorder
      den.aspects.apps.torrents.rtorrent
      den.aspects.apps.torrents.torrent-tui
      den.aspects.apps.torrents.webtorrent
      den.aspects.desktop.audio.visualization.cava
      den.aspects.apps.sysinfo.fastfetch
      den.aspects.apps.cli.p7zip
      den.aspects.apps.cli.ripgrep
      den.aspects.apps.disk.rufus
      den.aspects.apps.cli.zoxide
      den.aspects.system.virtualization.docker
      den.aspects.system.virtualization.kubernetes
      den.aspects.system.virtualization.qemu
      den.aspects.system.virtualization.waydroid
      den.aspects.desktop.theming.stylix
    ];
  };
}
