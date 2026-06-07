{inputs, ...}: {
  flake.modules.nixos.default = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    # Bootloader
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Swap
    zramSwap.enable = true;

    # Networking
    networking = {
      hostName = hostname;
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
      nameservers = ["8.8.8.8" "1.1.1.1"];
    };

    services.resolved.enable = true;

    # Localization
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

    # Firmware
    hardware.firmware = [
      pkgs.linux-firmware
    ];

    hardware.graphics.enable = true;
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Users
    users.users.${username} = {
      isNormalUser = true;
      description = username;
      extraGroups = [
        "networkmanager"
        "wheel"
        "adbusers"
        "kvm"
      ];
      packages = [];
    };

    nix.settings.trusted-users = [username];

    # Misc
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=-1
      Defaults timestamp_type=tty
    '';

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
  flake.modules.homeManager.default = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
