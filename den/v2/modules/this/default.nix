{
  flake.modules.nixos.this = { lib, config, pkgs, ... }: {
    options.this = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "default";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "ayin";
      };
    };
    config = {
      system.stateVersion = "25.11";

      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };

      zramSwap.enable = true;

      networking = {
        hostName = config.this.hostname;
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };

      services.resolved.enable = true;

      time.timeZone = "Asia/Ho_Chi_Minh";
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "vi_VN";
        LC_IDENTIFICATION = "vi_VN";
        LC_MEASUREMENT = "vi_VN";
        LC_MONETARY = "vi_VN";
        LC_NAME = "vi_VN";
        LC_NUMERIC = "vi_VN";
        LC_PAPER = "vi_VN";
        LC_TELEPHONE = "vi_VN";
        LC_TIME = "vi_VN";
      };

      hardware.firmware = [ pkgs.linux-firmware ];
      hardware.graphics.enable = true;
      hardware.enableRedistributableFirmware = lib.mkDefault true;

      users.users.${config.this.username} = {
        isNormalUser = true;
        description = config.this.username;
        extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" ];
        packages = [];
      };

      nix.settings.trusted-users = [config.this.username];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.substituters = [ "https://cache.nixos.org/" "https://cache.lix.systems" "https://nyx.chaotic.cx" ];
      nix.settings.trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" ];

      security.sudo.extraConfig = ''
        Defaults timestamp_timeout=-1
        Defaults timestamp_type=tty
      '';

      environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
    };
  };
  flake.modules.homeManager.this = { lib, config, ... }: {
    options.this = {
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "default";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "ayin";
      };
    };
    config = {
      home.stateVersion = "25.11";
      home.username = config.this.username;
      home.homeDirectory = "/home/${config.this.username}";

      programs.home-manager.enable = true;

      home.sessionVariables = {
        EDITOR = "hx";
        TERMINAL = "foot";
      };
    };
  };
}
