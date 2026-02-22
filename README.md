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
