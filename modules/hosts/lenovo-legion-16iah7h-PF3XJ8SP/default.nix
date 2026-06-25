{den, ...}: {
  den.hosts.x86_64-linux.lenovo-legion-16iah7h-PF3XJ8SP = {
    users.ayin = {
      includes = [
        den.aspects.users.ayin
        # den.batteries.primary-user
      ];
    };
  };

  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    includes = [
      den.batteries.primary-user

      den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.firmware
      den.aspects.lenovo-legion-16iah7h-PF3XJ8SP.hardware

      den.aspects.battery
      den.aspects.bluetooth
      den.aspects.bootloaders.systemd
      den.aspects.browsers.firefox
      den.aspects.browsers.vivaldi
      den.aspects.browsers.zen-browser
      den.aspects.compositors.sway
      den.aspects.dev
      den.aspects.editors.helix
      den.aspects.editors.zed-editor
      den.aspects.file-managers.thunar
      den.aspects.file-managers.yazi
      den.aspects.gaming.itch
      den.aspects.gaming.mangohud
      den.aspects.gaming.steam
      den.aspects.greeters.tuigreet
      den.aspects.kernels.cachyos-kernel
      den.aspects.launchers.tofi
      den.aspects.lockscreens.gtklock
      den.aspects.messenging.discord
      den.aspects.messenging.telegram
      den.aspects.multimedia.ffmpeg
      den.aspects.multimedia.gallery-dl
      den.aspects.multimedia.imv
      den.aspects.multimedia.mpv
      den.aspects.multimedia.obs-studio
      den.aspects.multimedia.yt-dlp
      den.aspects.music.youtube-music
      den.aspects.nix
      den.aspects.lix
      den.aspects.nh
      den.aspects.nix-ld
      den.aspects.nur
      den.aspects.office.notion
      den.aspects.office.pandoc
      den.aspects.office.taskwarrior
      den.aspects.office.texlive
      den.aspects.office.zathura
      den.aspects.services.cliphist
      den.aspects.services.fcitx5
      den.aspects.services.pipewire
      den.aspects.services.dconf
      den.aspects.services.gnome-keyring
      den.aspects.services.polkit
      den.aspects.services.cloudflare-warp
      den.aspects.services.nftables
      den.aspects.services.resolved
      den.aspects.settings
      den.aspects.shells.zsh
      den.aspects.status-bars.waybar
      den.aspects.swap.zram
      den.aspects.terminals.foot
      den.aspects.terminals.wezterm
      den.aspects.utilities.cava
      den.aspects.utilities.fastfetch
      den.aspects.utilities.rtorrent
      den.aspects.utilities.p7zip
      den.aspects.utilities.ripgrep
      den.aspects.utilities.speedtest-cli
      den.aspects.utilities.rufus
      den.aspects.virtualizations.docker
      den.aspects.virtualizations.waydroid
      den.aspects.stylix
    ];
  };
}
