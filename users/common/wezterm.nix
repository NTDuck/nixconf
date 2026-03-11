{ ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require "wezterm"

      function scheme_for_appearance(appearance)
        if appearance:find "Dark" then
          return "Catppuccin Mocha"
        else
          return "Catppuccin Latte"
        end
      end

      return {
        color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
        hide_tab_bar_if_only_one_tab = true,
      }
    '';  # https://wezterm.org/config/files.html
  };
}
