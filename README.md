# [NTDuck](https://github.com/NTDuck)'s nixconf

## Overview

OS: [NixOS 26.05 (Yarara)](https://nixos.org/blog/announcements/2026/nixos-2605/) <br>
Compositor: [Mango](https://mangowm.github.io/) <br>
Shell: [zsh](https://www.zsh.org/) 5.9.1, [starship](https://starship.rs/) / [Powerlevel10k](https://powerlevel10k.org/) <br>
Other Shell: [Noctalia v4.7.7](https://github.com/noctalia-dev/noctalia) <br>
Terminals: [Ghostty](https://ghostty.org/) / [Foot](https://codeberg.org/dnkl/foot) <br>
Fonts: [Inter](https://rsms.me/inter/), [Maple Mono](https://font.subf.dev/en/) <br>
Theme: [Grayscale Dark](https://tinted-theming.github.io/tinted-gallery/#base16-grayscale-dark), overriden <br>
Wallpapers: [葛飾 北斎's 神奈川沖浪裏 \[\[The Great Wave off Kanagawa\]\]](https://en.wikipedia.org/wiki/The_Great_Wave_off_Kanagawa) [Rockman](https://gruvbox-wallpapers.pages.dev/wallpapers/mix/rockman.png), [れおなるど's 図書館 \[\[Girls' Last Tour\]\]](https://x.com/LeoLeonardK10/status/1465607483372699656), [Anton Elfilter's Shifting Tides](https://x.com/elfilter_a/status/2043948619460411476), [nitrovu's ROARING GROUPCHAT](https://www.instagram.com/p/DM58MumtMC3/)

## Common Operations

### 1. Installation

On new machines, I usually install NixOS using the Calamares installer with no DE/WM selected, then run:

```bash
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes"
$ git clone https://github.com/NTDuck/nixconf && cd nixconf
$ sudo nixos-rebuild switch --flake .#${HOSTNAME} --extra-experimental-features "nix-command flakes"
```

Current supported hosts are `dell-latitude-E7270-H836QF2` and `lenovo-legion-16iah7h-PF3XJ8SP`.

### 2. Rebuild

```bash
$ nh os switch . -H ${HOSTNAME}
```

### 3. Update

Usually this involves recompiling heavy stuff so I apply certain limitations to avoid crashing.

```bash
$ NIX_CONFIG="$(printf \
  'access-tokens = github.com=%s\ncores = %d\nmax-jobs = 1\n' \
  "$(gh auth token)" \
  "$(( $(nproc) * 80 / 100 > 0 ))"
)" \
nh os switch . -H ${HOSTNAME} --update
```

## Screenshots

![sans.png](.github/assets/screenshots/sans.png)

## References

Different takes on the [Dendritic Pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) from [Pol Dellaiera](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/), [Spencer Balogh](https://blog.decent.id/post/flake-parts-and-dendritic-nix/), and [Simon Shine](https://simonshine.dk/articles/dendritic-nix-with-nixos-shell/).
