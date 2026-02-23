{ config, lib, pkgs, username, ... }:

{ 
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

  # Packages
  programs.git.enable = true;
  programs.git.settings.aliases.nccommit = "commit -a --allow-empty-message -m ''";  # https://trunk.io/blog/git-commit-messages-are-useless

  programs.gh.enable = true;
  programs.gh.gitCredentialHelper.enable = true;
  programs.gh.settings.git_protocol = "https";

  programs.niri.settings = {
    # Start essential programs on login
    spawn-at-startup = [
      { argv = [ "${pkgs.waybar}/bin/waybar" ]; }
      { argv = [ "${pkgs.mako}/bin/mako" ]; }
      # { argv = [ "${pkgs.swaybg}/bin/swaybg" "-c" "#000000" ]; }
    ];

    # Keybindings
    binds = {
      # Alacritty is already enabled in your common config!
      "Mod+Return".action.spawn = "alacritty";
      "Mod+D".action.spawn = "fuzzel";
      "Mod+Shift+E".action.quit.skip-confirmation = true;
      
      # Window management
      "Mod+Q".action.close-window = [];
      "Mod+Left".action.focus-column-left = [];
      "Mod+Right".action.focus-column-right = [];
    };
  };

  programs.alacritty.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox.enable = true;
}
