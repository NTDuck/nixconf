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

### 4. cool `nmcli` trick

```
$ nmcli connection add \
  type ethernet \
  con-name "ETH_VTIT_10.224.220.59" \
  ifname enp49s0 \
  autoconnect yes \
  connection.autoconnect-priority 100 \
  ip4 10.224.220.59/24 \
  gw4 10.224.220.1 \
  ipv4.dns "10.10.101.212 10.10.101.211" \
  ipv4.method manual \
  ipv6.method auto \
  proxy.method auto \
  proxy.pac-url "http://10.10.101.208/proxy.pac"

$ nmcli connection delete ETH_VTIT_10.224.220.59
```

### 4. Secrets Management (agenix)

Secrets are encrypted using [agenix](https://github.com/ryantm/agenix) via SSH key pairs. Secrets are automatically decrypted to `/run/agenix/` during NixOS system activation.

#### 1. Configuring Recipients (`secrets/secrets.nix`)

In `agenix`, two types of SSH public keys are defined:

- **User public keys** (e.g. `~/.ssh/id_ed25519.pub` or `https://github.com/<username>.keys`): Allows you to edit and decrypt secrets on your machine without `sudo`.
- **System host public keys** (e.g. `/etc/ssh/ssh_host_ed25519_key.pub`): Allows target hosts to decrypt secrets into `/run/agenix/` upon system activation.

```nix
let
  # User keys (for local editing without root)
  # ayin = "ssh-ed25519 AAA...";
  # users = [ ayin ];

  # Host keys (for system activation decryption)
  lenovo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMN7o3pdJqi7fPs85aiOytP/VSnts8d8LHmIvxb9tj8j root@lenovo-legion-16iah7h-PF3XJ8SP";
  systems = [ lenovo ];
in {
  "orca-key.age".publicKeys = systems; # or users ++ systems
}
```

#### 2. Creating / Editing Secrets (e.g. `ORCA_KEY`)

**With a user SSH key (recommended by agenix):**
Add your `~/.ssh/id_ed25519.pub` to `users` in `secrets/secrets.nix`, then edit secrets directly as a normal user:

```bash
agenix -e secrets/orca-key.age
```

**With the host SSH key directly:**
If no user key is configured yet, use the host's private key with `sudo -E` (so `$EDITOR` is preserved):

```bash
sudo -E agenix -e secrets/orca-key.age -i /etc/ssh/ssh_host_ed25519_key
```

#### 3. Rekeying & Deploying

After updating keys in `secrets/secrets.nix`:

```bash
agenix -r
# Or if using host key: sudo -E agenix -r -i /etc/ssh/ssh_host_ed25519_key
```

Stage changes and switch configuration:

```bash
git add secrets/
nh os switch . -H lenovo-legion-16iah7h-PF3XJ8SP
```

## Screenshots

![sans.png](.github/assets/screenshots/sans.png)

## References

Different takes on the [Dendritic Pattern](https://discourse.nixos.org/t/the-dendritic-pattern/61271) from [Pol Dellaiera](https://not-a-number.io/2025/refactoring-my-infrastructure-as-code-configurations/), [Spencer Balogh](https://blog.decent.id/post/flake-parts-and-dendritic-nix/), and [Simon Shine](https://simonshine.dk/articles/dendritic-nix-with-nixos-shell/).
