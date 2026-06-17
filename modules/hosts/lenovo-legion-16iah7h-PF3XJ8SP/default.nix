{den, ...}: {
  den.hosts.x86_64-linux.lenovo-legion-16iah7h-PF3XJ8SP = {
    users.ayin = {
      includes = [
        den.batteries.primary-user
        (den.batteries.user-shell "nushell")
      ];
    };
  };

  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    includes = [
      den.aspects.lenovo-legion

      den.aspects.agenix
      den.aspects.airllm
      den.aspects.battery
      den.aspects.bichannel
      den.aspects.bluetooth
      den.aspects.bluetuith
      den.aspects.boot
      den.aspects.cachyos-kernel
      den.aspects.cava
      den.aspects.cliphist
      den.aspects.cmake
      den.aspects.deno
      den.aspects.dev
      den.aspects.docker
      den.aspects.experimental-features
      den.aspects.fastfetch
      den.aspects.fcitx5
      den.aspects.ffmpeg
      den.aspects.firefox
      den.aspects.firmware
      den.aspects.gallery-dl
      den.aspects.gc
      den.aspects.gcc
      den.aspects.git-xet
      den.aspects.go
      den.aspects.gradle
      den.aspects.greetd
      den.aspects.helix
      den.aspects.hyprland
      den.aspects.imv
      den.aspects.itch
      den.aspects.lix
      den.aspects.llama
      den.aspects.llvm
      den.aspects.locale
      den.aspects.mangohud
      den.aspects.miktex
      den.aspects.mingw
      den.aspects.mpv
      den.aspects.network
      den.aspects.nh
      den.aspects.noctalia-shell
      den.aspects.nodejs
      den.aspects.notion
      den.aspects.nur
      den.aspects.nushell
      den.aspects.obs-studio
      den.aspects.ollama
      den.aspects.opencode
      den.aspects.openjdk
      den.aspects.openssh
      den.aspects.p7zip
      den.aspects.pandoc
      den.aspects.pear-desktop
      den.aspects.pipewire
      den.aspects.poetry
      den.aspects.protobuf
      den.aspects.protonvpn
      den.aspects.python
      den.aspects.rufus
      den.aspects.steam
      den.aspects.stylix
      den.aspects.swap
      den.aspects.taskwarrior
      den.aspects.telegram
      den.aspects.vesktop
      den.aspects.virtualbox
      den.aspects.vivaldi
      den.aspects.vortex
      den.aspects.waydroid
      den.aspects.webtorrent
      den.aspects.wezterm
      den.aspects.xmake
      den.aspects.yazi
      den.aspects.yt-dlp
      den.aspects.zalo
      den.aspects.zathura
      den.aspects.zed-editor
    ];
  };
}
