# [NTDuck](https://github.com/NTDuck)'s nixconf

## Overview

OS: [NixOS 26.05 (Yarara)](https://nixos.org/blog/announcements/2026/nixos-2605/) <br>
Compositor: [Mango](https://mangowm.github.io/) <br>
Shell: [zsh](https://www.zsh.org/) 5.9.1, [starship](https://starship.rs/) / [Powerlevel10k](https://powerlevel10k.org/) <br>
Other Shell: [Noctalia v4.7.7](https://github.com/noctalia-dev/noctalia) <br>
Terminals: [Ghostty](https://ghostty.org/) / [Foot](https://codeberg.org/dnkl/foot) <br>
Fonts: [Inter](https://rsms.me/inter/), [Maple Mono](https://font.subf.dev/en/) <br>
Theme: [Grayscale Dark](https://tinted-theming.github.io/tinted-gallery/#base16-grayscale-dark), overriden <br>
Wallpapers: [葛飾 北斎's 神奈川沖浪裏 \[\[The Great Wave off Kanagawa\]\]](https://en.wikipedia.org/wiki/The_Great_Wave_off_Kanagawa) [Rockman](https://gruvbox-wallpapers.pages.dev/wallpapers/mix/rockman.png), [れおなるど's 図書館 \[\[Girls' Last Tour\]\]](https://x.com/LeoLeonardK10/status/1465607483372699656), [Anton Elfilter's Shifting Tides](https://x.com/elfilter_a/status/2043948619460411476), [nitrovu's ROARING GROUPCHAT](https://www.instagram.com/p/DM58MumtMC3/), [nyancat](https://whvn.cc/j8kgpw)

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

### 4. Secrets Management (agenix)

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix) and decrypted automatically to `/run/agenix/` at system activation using SSH host keys (`/etc/ssh/ssh_host_ed25519_key`).

#### Recipients Configuration

Public keys for hosts and users are configured in `secrets/secrets.nix`:

```nix
let
  lenovo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMN7o3pdJqi7fPs85aiOytP/VSnts8d8LHmIvxb9tj8j root@lenovo-legion-16iah7h-PF3XJ8SP";
in {
  "orca-key.age".publicKeys = [lenovo];
}
```

#### Encrypting / Editing Secrets (e.g. `ORCA_KEY`)

To create or edit an encrypted secret (such as `ORCA_KEY` for Oh My Pi / OrcaRouter):

```bash
# Edit or create secrets/orca-key.age with an identity key (e.g. host SSH key)
sudo agenix -e secrets/orca-key.age -i /etc/ssh/ssh_host_ed25519_key

# Alternatively, encrypt directly with age:
echo -n "YOUR_ORCA_ROUTER_API_KEY" | age -R /etc/ssh/ssh_host_ed25519_key.pub -o secrets/orca-key.age

# Rekey all secrets after updating public keys in secrets/secrets.nix
sudo agenix -r -i /etc/ssh/ssh_host_ed25519_key
```

Remember to stage the modified `.age` files in git before rebuilding:

```bash
git add secrets/
```

## Screenshots

![sans.png](.github/assets/screenshots/sans.png)

## References

Different takes on the [Dendritic Pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) from [Pol Dellaiera](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/), [Spencer Balogh](https://blog.decent.id/post/flake-parts-and-dendritic-nix/), and [Simon Shine](https://simonshine.dk/articles/dendritic-nix-with-nixos-shell/).
