{den, ...}: {
  den.aspects.blob = {
    nixos = {
      lib,
      config,
      pkgs,
      host,
      user,
      ...
    }: {
      system.stateVersion = "24.05"; # See note below about 26.05
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      zramSwap.enable = true;
      networking = {
        hostName = host.name;
        networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        nameservers = ["8.8.8.8" "1.1.1.1"];
      };
      services.resolved.enable = true;
      time.timeZone = "Asia/Ho_Chi_Minh";
      i18n.defaultLocale = "en_US.UTF-8";
      hardware.firmware = [pkgs.linux-firmware];
      hardware.graphics.enable = true;
      hardware.enableRedistributableFirmware = lib.mkDefault true;
      users.users.${user.name} = {
        isNormalUser = true;
        description = user.name;
        extraGroups = ["networkmanager" "wheel" "adbusers" "kvm"];
        packages = [];
      };
      nix.settings.trusted-users = [user.name];
      nix.settings.experimental-features = ["nix-command" "flakes"];
      security.sudo.extraConfig = "Defaults timestamp_timeout=-1\nDefaults timestamp_type=tty";
    };

    homeManager = {
      lib,
      config,
      user,
      ...
    }: {
      home.stateVersion = "24.05"; # See note below about 26.05
      home.username = user.name;
      home.homeDirectory = "/home/${user.name}";
      programs.home-manager.enable = true;
      home.sessionVariables = {
        EDITOR = "hx";
        TERMINAL = "foot";
      };
    };
  };
}
