{den, ...}: {
  den.hosts.x86_64-linux.lenovo-legion-16iah7h-PF3XJ8SP = {
    users.ayin = {
      includes = [
        den.batteries.primary-user
        (den.batteries.user-shell "zsh")

        # ({den, ...}: {
        #   den.aspects.lenovo-legion-16iah7h-PF3XJ8SP-git = {
        #     homeManager = {
        #       programs.git.settings.user = {
        #         name = "NTDuck";
        #         email = "nguyentuduck@gmail.com";
        #       };
        #     };
        #   };
        # })
      ];
    };
  };

  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    includes = [
      den.batteries.primary-user

      den.aspects.lenovo-legion-16iah7h-PF3XJ8SP-hardware
      den.aspects.lenovo-legion-16iah7h-PF3XJ8SP-persist

      ({den, ...}: {
        den.aspects.lenovo-legion-16iah7h-PF3XJ8SP-temp-initial-password = {
          nixos = {
            users.users.ayin.initialPassword = "root";
          };
        };
      })

      den.aspects.agenix
      den.aspects.battery
      den.aspects.bichannel
      den.aspects.bluetooth
      den.aspects.bluetuith
      den.aspects.boot
      den.aspects.cachyos-kernel
      den.aspects.cava
      den.aspects.cliphist
      den.aspects.dev
      den.aspects.experimental-features
      den.aspects.fastfetch
      den.aspects.fcitx5
      den.aspects.firefox
      den.aspects.firmware
      den.aspects.foot
      den.aspects.gc
      den.aspects.greetd
      den.aspects.gtklock
      den.aspects.helix
      den.aspects.imv
      den.aspects.kanshi
      den.aspects.lenovo-legion
      den.aspects.lix
      den.aspects.locale
      den.aspects.mpv
      den.aspects.network
      den.aspects.nh
      den.aspects.nur
      den.aspects.openssh
      den.aspects.pear-desktop
      den.aspects.pipewire
      den.aspects.steam
      den.aspects.stylix
      den.aspects.swap
      den.aspects.sway
      den.aspects.taskwarrior
      den.aspects.tofi
      den.aspects.vesktop
      den.aspects.waybar
      den.aspects.yazi
      den.aspects.zalo
      den.aspects.zathura
      den.aspects.zed-editor
      den.aspects.zsh
    ];
  };
}
