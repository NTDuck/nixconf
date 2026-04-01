{ pkgs, username, ... }:

{
  programs.hyprlock = {
    enable = true;
    package = pkgs.unstable.hyprlock;

    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = false;
      };

      background = [
        {
          monitor = "";
          # You can replace this with a classic Windows 7 wallpaper path
          path = "${../../assets/wallpapers/girls-last-tour-library.jpg}";
          blur_passes = 2;
          blur_size = 4;
          color = "rgba(25, 20, 20, 1.0)";
        }
      ];

      image = [
        {
          monitor = "";
          # Place a profile picture at ~/.face.icon or change this path
          path = "/home/${username}/.face.icon";
          size = 140;
          rounding = 15; # Win7 avatars were slightly rounded squares
          border_size = 4;
          border_color = "rgba(255, 255, 255, 1.0)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$USER";
          color = "rgba(255, 255, 255, 1.0)";
          font_size = 28;
          font_family = "Segoe UI, sans-serif"; # Classic Win7 font
          position = "0, -40";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "220, 35";
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgba(180, 180, 180, 1.0)";
          inner_color = "rgba(255, 255, 255, 1.0)"; # White box like Win7
          font_color = "rgba(0, 0, 0, 1.0)";        # Black typing text
          fade_on_empty = false;
          placeholder_text = "<i>Password</i>";
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
