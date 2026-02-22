{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "dell-latitude-E7270-H836QF2";
  networking.networkmanager.enable = true;

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

  # Users
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nix.settings.trusted-users = [ username ];

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
  
  # Firmware
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  hardware.enableRedistributableFirmware = true;

  # Packages
  nixpkgs.config.allowUnfree = true;

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  environment.systemPackages = with pkgs; [
    git
    powertop
    brightnessctl
    pamixer
    fastfetch
  ];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # # Window Manager
  # programs.niri.enable = true;

  # Audio
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;

  services.pulseaudio.enable = false;

  # Printing
  # services.printing.enable = true;

  # Fonts
  # fonts = {};

  # Battery
  services.tlp.enable = true;
  services.thermald.enable = true;
  services.fstrim.enable = true;

  services.power-profiles-daemon.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}