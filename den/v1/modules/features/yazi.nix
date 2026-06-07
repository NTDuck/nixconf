{inputs, ...}: {
  flake.modules.homeManager.yazi = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    programs.yazi = {
      enable = true;
      package = pkgs.unstable.yazi;

      enableZshIntegration = true;
      shellWrapperName = "y";

      settings = {
        manager = {
          show_hidden = false;
          sort_by = "modified";
          sort_dir_first = true;
          sort_reverse = true;
          linemode = "size";
          show_symlink = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
          image_filter = "lanczos3";
          image_quality = 90;
          sixel_fraction = 10;
        };
      };

      keymap = {
        manager.prepend_keymap = [
          {
            on = ["g" "d"];
            run = "cd ~/Downloads";
            desc = "RUN cd ~/Downloads";
          }
        ];
      };
    };
  };
}
