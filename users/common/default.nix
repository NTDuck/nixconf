{ username, ... }:

{
  imports = [
    ./bemenu.nix
    ./cliphist.nix
    ./fastfetch.nix
    ./firefox.nix
    ./foot.nix
    ./gh.nix
    ./git.nix
    ./helix.nix
    ./imv.nix
    ./kanshi.nix
    ./mpv.nix
    ./sway.nix
    ./vesktop.nix
    ./yazi.nix
    ./zed-editor.nix
    ./zsh.nix
  ];

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
}
