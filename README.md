# nixos-cfg
```cmd
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes"
$ git clone https://github.com/NTDuck/nixos-cfg && cd nixos-cfg
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```

## TODOs
- Compositor: Sway
- Terminal: foot
- Shell: zsh + starship/powerlevel10k

- Consider [undervolting], tlp
- Add support for HDMI
- Change rule of Nix language server e.g. { a, b, c, ... } does not need newlining
- Font
- Theme
- Image & Video viewers
- Bemenu settings
- Cloud for lock screen
- Make bamboo not show gui when switching language input
- Wallpaper

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
```

## Assets
- [./assets/wallpapers/funeral-of-the-dead-butterflies-background.png](https://limbuscompany.wiki.gg/wiki/Solemn_Lament_Gregor)
- [./assets/wallpapers/funeral-of-the-dead-butterflies-hokma.png](https://reactor.cc/post/3910571)
- [./assets/wallpapers/funeral-of-the-dead-butterflies.png](https://x.com/MaskV_/status/1675409368651816960)
- [./assets/wallpapers/lobotomy-ego-solemn-lament-yi-sang.jpg](https://www.pinterest.com/pin/16888567439645056/)
