# nixos-cfg

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
$ nix flake update

$ sudo nixos-rebuild switch --flake github:NTDuck/nixos-cfg#dell-latitude-E7270-H836QF2 --refresh --no-write-lock-file
```

```cmd
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes"
$ git clone https://github.com/NTDuck/nixos-cfg && cd nixos-cfg
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```

## Assets
- [./assets/wallpapers/funeral-of-the-dead-butterflies-background.png](https://limbuscompany.wiki.gg/wiki/Solemn_Lament_Gregor)
- [./assets/wallpapers/funeral-of-the-dead-butterflies-hokma.png](https://reactor.cc/post/3910571)
- [./assets/wallpapers/funeral-of-the-dead-butterflies.png](https://x.com/MaskV_/status/1675409368651816960)
- [./assets/wallpapers/lobotomy-ego-solemn-lament-yi-sang.jpg](https://www.pinterest.com/pin/16888567439645056/)
