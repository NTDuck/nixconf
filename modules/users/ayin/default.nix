{
  den,
  config,
  lib,
  ...
}: {
  den.schema.user.config.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.x86_64-linux."dell-latitude-E7270-H836QF2" = {
    users.ayin = {};
  };

  den.hosts.x86_64-linux."lenovo-legion-pro-16-iah7h" = {
    users.ayin = {};
  };
  den.aspects.ayin = {
    includes = [
      config.den.aspects.agenix
      config.den.aspects.agentBrowser
      config.den.aspects.alejandra
      config.den.aspects.antigravityCli
      config.den.aspects.antigravityUsage
      config.den.aspects.base
      config.den.aspects.homeManager
      config.den.aspects.nixpkgsOverlays
      config.den.aspects.bluetuith
      config.den.aspects.cCpp
      config.den.aspects.cava
      config.den.aspects.claudeCode
      config.den.aspects.cliphist
      config.den.aspects.cloudflareWarp
      config.den.aspects.codex
      config.den.aspects.docker
      config.den.aspects.fastfetch
      config.den.aspects.fcitx5
      config.den.aspects.firefox
      config.den.aspects.foot
      config.den.aspects.gc
      config.den.aspects.gh
      config.den.aspects.git
      config.den.aspects.glab
      config.den.aspects.greetd
      config.den.aspects.gtklock
      config.den.aspects.helix
      config.den.aspects.imv
      config.den.aspects.javaKotlin
      config.den.aspects.javascriptTypescript
      config.den.aspects.kanshi
      config.den.aspects.lix
      config.den.aspects.lua
      config.den.aspects.mpv
      config.den.aspects.nh
      config.den.aspects.nix
      config.den.aspects.ollama
      config.den.aspects.openssh
      config.den.aspects.pearDesktop
      config.den.aspects.pipewire
      config.den.aspects.protobuf
      config.den.aspects.python
      config.den.aspects.qoderCli
      config.den.aspects.rust
      config.den.aspects.speedtestCli
      config.den.aspects.steam
      config.den.aspects.stylix
      config.den.aspects.sway
      config.den.aspects.taskwarrior
      config.den.aspects.tofi
      config.den.aspects.topiary
      config.den.aspects.users
      config.den.aspects.vesktop
      config.den.aspects.waybar
      config.den.aspects.waydroid
      config.den.aspects.yazi
      config.den.aspects.zalo
      config.den.aspects.zathura
      config.den.aspects.zedEditor
      config.den.aspects.zsh
    ];
  };
}
