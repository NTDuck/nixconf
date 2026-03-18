{
  lib,
  pkgs,
  username,
  hostname,
  ...
}:

{
  imports = [
    ./cachyos-kernel.nix
    ./catppuccin.nix
    ./dev.nix
    ./greetd.nix
    ./niri.nix
    ./zeroclaw.nix
    ./zsh.nix
  ];

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
    networkmanager.enable = true;
  };

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

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 4d";
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  services.pulseaudio.enable = lib.mkDefault false;

  # Printing
  services.printing.enable = true;

  # Firmware
  hardware.firmware = [
    pkgs.linux-firmware
  ];

  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Packages
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  environment.systemPackages = [
    pkgs.git
  ];

  # Battery
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.fstrim.enable = true;

  services.power-profiles-daemon.enable = false;

  # Users
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = [ ];
  };

  nix.settings.trusted-users = [ username ];

  # Access tokens
  # nix.settings.access-tokens = [ (import ../../secrets/common/github-pat-classic.nix) ];

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
}
