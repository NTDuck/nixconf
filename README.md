# nixos-cfg

## Overview
- Compositor: [sway](https://github.com/swaywm/sway)
- Bar: [waybar](https://github.com/Alexays/Waybar)
- Terminal: [foot](https://codeberg.org/dnkl/foot)
- Launcher: [tofi](https://github.com/philj56/tofi)
- Fonts:
  JetBrainsMono Nerd Font - Monospace |
  Lora - Serif |
  Inter - Sans-serif |
  Noto Color Emoji - Emoji
- Theme: [charcoal-dark](https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/charcoal-dark.yaml)
<!--- Wallpaper: [./assets/wallpapers/girls-last-tour-library.jpg](https://x.com/LeoLeonardK10/status/1465607483372699656)-->
- Wallpaper: [./assets/wallpapers/shifting-tides.jpg](https://x.com/elfilter_a/status/2043948619460411476)

## Deployment
```cmd
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes"
$ git clone https://github.com/NTDuck/nixos-cfg && cd nixos-cfg
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```

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

$ lsblk # to determine ${diskpartition}
$ sudo mount -o subvol=persistent /dev/${diskpartition} /mnt
$ sudo cp ~/nixconf/* /mnt/etc/nixconf

sudo chroot /mnt passwd
```
