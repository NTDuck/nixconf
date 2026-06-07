{
  flake.modules.nixos.hosts-dell-latitude-E7270-H836QF2 = {
    inputs,
    config,
    pkgs,
    ...
  }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    imports = [
      inputs.self.modules.nixos.dell-latitude-E7270-H836QF2-battery
      inputs.self.modules.nixos.dell-latitude-E7270-H836QF2-drivers
      inputs.self.modules.nixos.dell-latitude-E7270-H836QF2-hardware
      inputs.self.modules.nixos.dell-latitude-E7270-H836QF2-bluetooth

      (
        {pkgs, ...}: {
          nixpkgs.config.allowUnfree = true;
          nixpkgs.overlays = [
            inputs.nur.overlays.default
            inputs.rust-overlay.overlays.default
            (final: prev: {
              unstable = import inputs.nixpkgs {
                system = pkgs.system;
                config.allowUnfree = true;
              };
            })
          ];
        }
      )

      inputs.self.modules.nixos.this
      inputs.self.modules.nixos.this-share-home

      inputs.self.modules.nixos.agenix
      inputs.self.modules.nixos.alejandra
      inputs.self.modules.nixos.battery
      inputs.self.modules.nixos.bluetooth
      inputs.self.modules.nixos.cachyos-kernel
      inputs.self.modules.nixos.cloudflare-warp
      inputs.self.modules.nixos.fcitx5
      inputs.self.modules.nixos.gc
      inputs.self.modules.nixos.gpt4free
      inputs.self.modules.nixos.greetd
      inputs.self.modules.nixos.gtklock
      inputs.self.modules.nixos.openssh
      inputs.self.modules.nixos.pipewire
      inputs.self.modules.nixos.steam
      inputs.self.modules.nixos.stylix
      inputs.self.modules.nixos.sway
      inputs.self.modules.nixos.waydroid
      inputs.self.modules.nixos.zsh
      inputs.self.modules.nixos.lix
      inputs.self.modules.nixos.speedtest
      inputs.self.modules.nixos.nh

      {this.hostname = "dell-latitude-E7270-H836QF2";}

      inputs.self.modules.nixos.this-home-manager
      {
        home-manager.users.ayin = {
          imports = [
            inputs.self.modules.homeManager.agenix
            inputs.self.modules.homeManager.cava
            inputs.self.modules.homeManager.cliphist
            inputs.self.modules.homeManager.dev-pkgs
            inputs.self.modules.homeManager.fastfetch
            inputs.self.modules.homeManager.firefox
            inputs.self.modules.homeManager.foot
            inputs.self.modules.homeManager.gh
            inputs.self.modules.homeManager.glab
            inputs.self.modules.homeManager.git
            inputs.self.modules.homeManager.helix
            inputs.self.modules.homeManager.imv
            inputs.self.modules.homeManager.kanshi
            inputs.self.modules.homeManager.mpv
            inputs.self.modules.homeManager.pear-desktop
            inputs.self.modules.homeManager.sway
            inputs.self.modules.homeManager.taskwarrior
            inputs.self.modules.homeManager.termusic
            inputs.self.modules.homeManager.tofi
            inputs.self.modules.homeManager.vesktop
            inputs.self.modules.homeManager.waybar
            inputs.self.modules.homeManager.yazi
            inputs.self.modules.homeManager.zalo
            inputs.self.modules.homeManager.zathura
            inputs.self.modules.homeManager.zed-editor
            inputs.self.modules.homeManager.antigravity-usage
          ];
        };
      }
    ];
  };
}
