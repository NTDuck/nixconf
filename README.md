# nixos-cfg

## Overview
- Compositor: [Mango](https://github.com/mangowm/mango)
- Shell: [Noctalia v4.7.7](https://github.com/noctalia-dev/noctalia)
- Terminals: [Kitty](https://sw.kovidgoyal.net/kitty/) & [Foot](https://codeberg.org/dnkl/foot)
- Fonts: <PENDING>
- Theme: [Grayscale Dark](https://tinted-theming.github.io/tinted-gallery/#base16-grayscale-dark), overriden
- Wallpapers: 
  - [./assets/wallpapers/girls-last-tour-library.jpg](https://x.com/LeoLeonardK10/status/1465607483372699656)
  - [./assets/wallpapers/shifting-tides.jpg](https://x.com/elfilter_a/status/2043948619460411476)
  - [./assets/wallpapers/rockman.png](https://gruvbox-wallpapers.pages.dev/wallpapers/mix/rockman.png)


NIX_CONFIG="$(printf \
  'access-tokens = github.com=%s\ncores = 16\nmax-jobs = 1\n' \
  "$(gh auth token)"
)" \
nh os switch . \
  -H lenovo-legion-16iah7h-PF3XJ8SP --update


## References
- https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/
- https://blog.decent.id/post/flake-parts-and-dendritic-nix/
- https://simonshine.dk/articles/dendritic-nix-with-nixos-shell/

## Deployment
```cmd
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes pipe-operators"
$ git clone https://github.com/NTDuck/nixconf && cd nixconf
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```

## Validation
```cmd
$ alejandra modules flake.nix
$ nix flake check
```

The configuration avoids Nix pipe-operator syntax, so evaluators only need the standard `nix-command` and `flakes` experimental features.

## Adding a user
Declare the user on each target host, then define the user's personal aspect at `den.aspects.<username>`. Do not include one user's aspect in a host include list; that would project personal Home Manager settings to every user on the host.

## Agenix lifecycle
### Public key generation - Target
```cmd
$ sudo mkdir -p /etc/ssh
$ sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
$ cat /etc/ssh/ssh_host_ed25519_key.pub
```

### Public key generation - User
```cmd
$ ssh-keygen -t ed25519 -C "ayin@dell-latitude"
$ cat ~/.ssh/id_ed25519.pub
```

### Secret creation
```cmd
cd secrets
nix run github:ryantm/agenix -- -e my-secret.age
agenix -e my-secret.age
```

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
```

### How to install on new machine
```cmd
# In case it shows something like "Virtual Terminal Stopped: Device memory is nearly full. Virtual terminal processes were using a lot of memory and were forced to stop."
$ sudo dd if=/dev/zero of=/swapfile bs=1M count=8192
$ sudo chmod 600 /swapfile
$ sudo mkswap /swapfile
$ sudo swapon /swapfile

$ sudo rm -f /swapfile
$ sudo modprobe zram
$ echo 8G | sudo tee /sys/block/zram0/disksize
$ sudo mkswap /dev/zram0
$ sudo swapon /dev/zram0
```

```cmd
$ git clone https://github.com/NTDuck/nixconf && nixconf

$ sudo nixos-generate-config --show-hardware-config --no-filesystems > ./modules/hosts/${hostname}/private/hardware/default.nix
$ sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko/latest#disko-install -- --flake .#${hostname} --disk main /dev/${diskname}

$ ...
$ git add .

$ lsblk # to determine ${diskpartition}
$ sudo mount -o subvol=persistent /dev/${diskpartition} /mnt
$ sudo cp ~/nixconf/* /mnt/etc/nixconf

$ sudo chroot /mnt passwd
```
