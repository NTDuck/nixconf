# nixos-cfg

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
$ nix flake update

$ sudo nixos-rebuild switch --flake github:NTDuck/nixos-cfg#dell-latitude-E7270-H836QF2 --refresh --no-write-lock-file
```