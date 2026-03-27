{ ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require "wezterm"

      return {
        hide_tab_bar_if_only_one_tab = true,
      }
    '';  # https://wezterm.org/config/files.html
  };

  catppuccin.wezterm = {
    enable = true;
    apply = true;
  };
}
