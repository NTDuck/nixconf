{
  den,
  config,
  ...
}: {
  den.hosts.x86_64-linux.dell-latitude-E7270-H836QF2 = {
    users.ayin = {
      includes = [
        den.batteries.primary-user
        (den.batteries.user-shell "zsh")
        den.aspects.blob
      ];
    };
  };

  den.aspects.dell-latitude-E7270-H836QF2 = {
    includes = [
      (den.batteries.import-tree ./private)

      den.aspects.agenix
      den.aspects.agent-browser
      den.aspects.alejandra
      den.aspects.antigravity-cli
      den.aspects.antigravity-usage
      den.aspects.nixpkgs-overlays
      den.aspects.battery
      den.aspects.bluetooth
      den.aspects.bluetuith
      den.aspects.cachyos-kernel
      den.aspects.c-cpp
      den.aspects.cava
      den.aspects.claude-code
      den.aspects.cliphist
      den.aspects.cloudflare-warp
      den.aspects.codex
      den.aspects.docker
      den.aspects.fastfetch
      den.aspects.fcitx5
      den.aspects.firefox
      den.aspects.foot
      den.aspects.gc
      den.aspects.gh
      den.aspects.git
      den.aspects.glab
      den.aspects.greetd
      den.aspects.gtklock
      den.aspects.helix
      den.aspects.imv
      den.aspects.java-kotlin
      den.aspects.javascript-typescript
      den.aspects.kanshi
      den.aspects.lix
      den.aspects.lua
      den.aspects.mpv
      den.aspects.nh
      den.aspects.nix
      den.aspects.ollama
      den.aspects.openssh
      den.aspects.pear-desktop
      den.aspects.pipewire
      den.aspects.protobuf
      den.aspects.python
      den.aspects.qoder-cli
      den.aspects.rust
      den.aspects.speedtest-cli
      den.aspects.steam
      den.aspects.stylix
      den.aspects.sway
      den.aspects.taskwarrior
      den.aspects.tofi
      den.aspects.topiary
      den.aspects.vesktop
      den.aspects.waybar
      den.aspects.waydroid
      den.aspects.yazi
      den.aspects.zalo
      den.aspects.zathura
      den.aspects.zed-editor
      den.aspects.zsh
    ];
  };
}
