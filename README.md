# nixos-cfg
```cmd
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes"
$ git clone https://github.com/NTDuck/nixos-cfg && cd nixos-cfg
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```

## Overview
- Compositor: Sway
- Bar: swaybar + i3status-rust
- Terminal: foot
- Launcher: bemenu
- Fonts: ...
- Theme: ...

## TODOs
- Compositor: Sway
- Terminal: foot
- Shell: zsh + starship/powerlevel10k

- Add support for HDMI (work?)
- Change rule of Nix language server e.g. { a, b, c, ... } does not need newlining
- Cloud for lock screen

- nixos system stable + pkgs unstable
- Make bamboo not show gui when switching language input
- foot transparent
- gnome keyring persist, intuition: pw
- disable underlining
- make kernel work
- warp equivalent
- powerlevel10k for zsh
- android studio
- make fastfetch stop "bleeding" consistent output idk
- zen browser

- add gaps & borders
- make the status bar 
- use i3status-rust backend
- use a nicer tuigreet theme
- bemenu
- change bar to: [left] ws, current window title [middle] time (HH:mm) [right] volume% + icon to show mute or not, brightness%, cpu+ram(+gpu if possible) usage, battery; also make current 

* curr bar: [left] ws [middle] [right] network bat sto ? ram ? datetime

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
```

## Assets
- [./assets/wallpapers/funeral-of-the-dead-butterflies-background.png](https://limbuscompany.wiki.gg/wiki/Solemn_Lament_Gregor)
- [./assets/wallpapers/funeral-of-the-dead-butterflies-hokma.png](https://reactor.cc/post/3910571)
- [./assets/wallpapers/funeral-of-the-dead-butterflies.png](https://x.com/MaskV_/status/1675409368651816960)
- [./assets/wallpapers/lobotomy-ego-solemn-lament-yi-sang.jpg](https://www.pinterest.com/pin/16888567439645056/)
- [./assets/wallpapers/girls-last-tour-library.jpg](https://x.com/LeoLeonardK10/status/1465607483372699656)
