{ pkgs, username, ... }:

{
  imports = [
    ./niri  # default.nix
    ./shell

    ./cliphist.nix
    ./fastfetch.nix
    ./firefox.nix
    ./git.nix
    ./helix.nix
    ./tofi.nix
    ./wezterm.nix
    ./yazi.nix
    ./zed-editor.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Packages
  home.packages = [
    pkgs.base16-schemes  # stylix
    pkgs.nixfmt
  ];

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
}
