{ den, ... }:
{
  den.aspects."base" = {
    nixos = { lib, config, pkgs, ... }: {
      options.this = {
        hostname = lib.mkOption { type = lib.types.str; default = "default"; };
        username = lib.mkOption { type = lib.types.str; default = "ayin"; };
      };
      config = {
        system.stateVersion = "26.05";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        zramSwap.enable = true;
        networking = {
          hostName = config.this.hostname;
          networkmanager = { enable = true; dns = "systemd-resolved"; };
          nameservers = ["8.8.8.8" "1.1.1.1"];
        };
        services.resolved.enable = true;
        time.timeZone = "Asia/Ho_Chi_Minh";
        i18n.defaultLocale = "en_US.UTF-8";
        hardware.firmware = [pkgs.linux-firmware];
        hardware.graphics.enable = true;
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        users.users.${config.this.username} = {
          isNormalUser = true;
          description = config.this.username;
          extraGroups = ["networkmanager" "wheel" "adbusers" "kvm"];
          packages = [];
        };
        nix.settings.trusted-users = [config.this.username];
        nix.settings.experimental-features = ["nix-command" "flakes"];
        security.sudo.extraConfig = "Defaults timestamp_timeout=-1\nDefaults timestamp_type=tty";
      };
    };
    homeManager = { lib, config, ... }: {
      options.this = {
        hostname = lib.mkOption { type = lib.types.str; default = "default"; };
        username = lib.mkOption { type = lib.types.str; default = "ayin"; };
      };
      config = {
        home.stateVersion = "26.05";
        home.username = config.this.username;
        home.homeDirectory = "/home/${config.this.username}";
        programs.home-manager.enable = true;
        home.sessionVariables = { EDITOR = "hx"; TERMINAL = "foot"; };
      };
    };
  };
}
