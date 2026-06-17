{den, ...}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {
      includes = [
        den.batteries.primary-user
        (den.batteries.user-shell "zsh")
      ];
    };
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      den.aspects.dell-latitude-E7270-H836QF2-bluetooth-driver
      den.aspects.dell-latitude-E7270-H836QF2-network-driver
      den.aspects.dell-latitude-E7270-H836QF2-hardware

      den.aspects.agenix
      den.aspects.bichannel
      den.aspects.battery
      den.aspects.boot
      den.aspects.experimental-features
      den.aspects.firmware
      den.aspects.locale
      den.aspects.network
      den.aspects.swap
      den.aspects.bluetooth
      den.aspects.bluetuith
      den.aspects.cachyos-kernel
      den.aspects.cava
      den.aspects.cliphist
      den.aspects.dev
      den.aspects.fastfetch
      den.aspects.fcitx5
      den.aspects.firefox
      den.aspects.foot
      den.aspects.gc
      den.aspects.greetd
      den.aspects.gtklock
      den.aspects.helix
      den.aspects.imv
      den.aspects.kanshi
      den.aspects.lix
      den.aspects.mpv
      den.aspects.nh
      den.aspects.nur
      den.aspects.openssh
      den.aspects.pear-desktop
      den.aspects.pipewire
      den.aspects.steam
      den.aspects.stylix
      den.aspects.sway
      den.aspects.taskwarrior
      den.aspects.tofi
      den.aspects.vesktop
      den.aspects.waybar
      den.aspects.waydroid
      den.aspects.yazi
      den.aspects.zalo
      den.aspects.zathura
      den.aspects.zed-editor
      den.aspects.zsh
      den.aspects.nodejs
      den.aspects.p7zip
    ];
  };
}
