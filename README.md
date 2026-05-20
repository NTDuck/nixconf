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

## TODOs
- Add support for HDMI (work?)

- Make bamboo not show gui when switching language input - disable underlining

```cmd
$ sudo nixos-generate-config --show-hardware-config > ./targets/dell-latitude-E7270-H836QF2/hardware.nix
```


<!--
IMPORTANT: Write up the specifications into the ".gemini/specs/" folder with each domain topic (including technical topic) as a seperate markdown file. Create a ".gemini/specs/SPECS.md" which is an overview document that contains a table that links to all the specs.
-->
