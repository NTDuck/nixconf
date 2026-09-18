{den, ...}: {
  den.hosts.x86_64-linux.lenovo-legion-16iah7h-PF3XJ8SP = {
    users.ayin = {};
  };

  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    includes = [
      # power-profiles-daemon deliberately EXCLUDED (2026-09-15): its
      # profile set (low-power/balanced/performance) cannot represent
      # legion's "custom" profile, and its reassertion overwrites a
      # custom-mode write seconds later — legion_gui's custom mode
      # "jumps back" to the previous mode with PPD running (proven:
      # custom sticks indefinitely with PPD stopped, reverts ~2s with it
      # active). legion_laptop drives platform_profile itself. upower
      # stays for battery telemetry.
      den.aspects.apps.browsers.chromium
      den.aspects.apps.browsers.zen-browser
      den.aspects.apps.p7zip
      den.aspects.apps.ripgrep
      den.aspects.apps.zoxide
      den.aspects.apps.rufus
      den.aspects.apps.editors.helix
      den.aspects.apps.editors.zed-editor
      den.aspects.apps.file-managers.nemo
      den.aspects.apps.file-managers.tfm
      den.aspects.apps.gaming.itch
      den.aspects.apps.gaming.mangohud
      den.aspects.apps.gaming.rpgmakermlinux-cicpoffs
      den.aspects.apps.gaming.roleplaying.risuai
      den.aspects.apps.gaming.roleplaying.sillytavern
      den.aspects.apps.gaming.roleplaying.rp
      den.aspects.apps.gaming.steam
      den.aspects.apps.gaming.wine
      den.aspects.apps.gaming.wlib
      den.aspects.remote-desktop.sunshine
      den.aspects.system.network.tailscale
      den.aspects.apps.messaging.discord
      den.aspects.apps.messaging.lark-cli
      den.aspects.apps.messaging.telegram
      den.aspects.apps.multimedia.ffmpeg
      den.aspects.apps.multimedia.gallery-dl
      den.aspects.apps.multimedia.imv
      den.aspects.apps.multimedia.mpv
      den.aspects.apps.multimedia.obs-studio
      den.aspects.apps.multimedia.yt-dlp
      den.aspects.apps.multimedia.youtube-music
      den.aspects.apps.office.libreoffice
      den.aspects.apps.office.pandoc
      den.aspects.apps.office.texlive
      den.aspects.apps.office.zathura
      den.aspects.apps.mermaid
      den.aspects.apps.editors.obsidian
      den.aspects.apps.taskwarrior
      den.aspects.apps.tomato
      den.aspects.apps.world-monitor
      den.aspects.apps.fastfetch
      den.aspects.apps.terminals.ghostty
      den.aspects.apps.torrents.rtorrent
      den.aspects.apps.torrents.torrent-tui
      den.aspects.apps.torrents.webtorrent
      den.aspects.dev
      den.aspects.system.bluetooth
      den.aspects.system.boot.systemd
      den.aspects.system.hardware.openrgb
      den.aspects.system.kernel.cachyos-kernel
      den.aspects.system.network.cloudflare-warp
      den.aspects.system.network.nftables
      den.aspects.system.network.protonvpn
      den.aspects.system.network.resolved
      den.aspects.system.network.ssh
      den.aspects.system.nix
      den.aspects.system.nix.lix
      den.aspects.system.secrets.agenix
      den.aspects.system.settings
      den.aspects.system.storage.udisks2
      den.aspects.system.swap.zram
      den.aspects.system.virtualization.docker
      den.aspects.system.virtualization.kubernetes
      den.aspects.system.virtualization.qemu
      den.aspects.system.virtualization.waydroid
      (den.aspects.desktop.compositors.mangowm {
        terminal = pkgs: "${pkgs.unstable.ghostty}/bin/ghostty";
      })
      den.aspects.desktop.audio.pipewire
      den.aspects.desktop.audio.visualization.cava
      den.aspects.desktop.auth.gnome-keyring
      den.aspects.desktop.auth.polkit
      den.aspects.desktop.clipboard.cliphist
      den.aspects.desktop.fs.gvfs
      (den.aspects.desktop.greeters.tuigreet {
        command = config: "${config.programs.mango.package}/bin/mango";
      })
      den.aspects.desktop.input.fcitx5
      den.aspects.desktop.input.keyd
      {
        internalOutput = "eDP-1";

        externalOutputs = [
          "HDMI-A-1"
          "HDMI-A-2"
          "HDMI-1"
          "HDMI-2"
        ];
      }
      den.aspects.desktop.panels.noctalia
      (den.aspects.desktop.portals.xdg {internalOutput = "eDP-1";})
      den.aspects.desktop.screenshots.flameshot
      den.aspects.desktop.screenshots.gpu-screen-recorder
      den.aspects.desktop.settings.dconf
      den.aspects.desktop.shells.prompts.starship
      den.aspects.desktop.shells.zsh
      den.aspects.desktop.theming.stylix
      den.aspects.desktop.wayland.kanshi
    ];
  };
}
