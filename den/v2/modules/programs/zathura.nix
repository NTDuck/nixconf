{
  flake.modules.homeManager.zathura = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.zathura = {
      enable = true;
      package = pkgs.unstable.zathura;

      options = {
        adjust-open = "width"; # "best-fit"
        double-click-follow = "false";
        font = "${config.stylix.fonts.monospace.name} normal ${toString config.stylix.fonts.sizes.applications}";
        guioptions = "chv";
        page-v-padding = "2";
        page-h-padding = "2";
        pages-per-row = "1";
        scroll-step = "100";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        selection-clipboard = "clipboard";
        zoom-min = "10";
      };

      mappings = {
        "[fullscreen] a" = "adjust_window best-fit";
        "[fullscreen] s" = "adjust_window width";
        "<C-i>" = "zoom in";
        "<C-o>" = "zoom out";
      };
    };
  };
}
