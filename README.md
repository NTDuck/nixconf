# [NTDuck](https://github.com/NTDuck)'s nixconf

## Overview
Compositor: [Mango](https://github.com/mangowm/mango)<br>
Shell: [Zsh](https://www.zsh.org/) + starship / powerlevel10k<br>
Other Shell: [Noctalia v4.7.7](https://github.com/noctalia-dev/noctalia) <br>
Terminals: [Kitty](https://sw.kovidgoyal.net/kitty/) / [Foot](https://codeberg.org/dnkl/foot) <br>
Fonts: <PENDING> <br>
Theme: [Grayscale Dark](https://tinted-theming.github.io/tinted-gallery/#base16-grayscale-dark), overriden <br>
Wallpapers: [Rockman](https://gruvbox-wallpapers.pages.dev/wallpapers/mix/rockman.png), [れおなるど's 図書館 \[\[Girls' Last Tour\]\]](https://x.com/LeoLeonardK10/status/1465607483372699656), [Anton Elfilter's Shifting Tides](https://x.com/elfilter_a/status/2043948619460411476)

## Common Operations
1. Installation
```bash
$ nix shell nixpkgs#git --extra-experimental-features "nix-command flakes pipe-operators"
$ git clone https://github.com/NTDuck/nixconf && cd nixconf
$ sudo nixos-rebuild switch --flake .#dell-latitude-E7270-H836QF2
```
2. Rebuild
```bash
```
3. Update
```bash
```

## References
- https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/
- https://blog.decent.id/post/flake-parts-and-dendritic-nix/
- https://simonshine.dk/articles/dendritic-nix-with-nixos-shell/
