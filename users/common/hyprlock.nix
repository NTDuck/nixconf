{ pkgs, username, lib, ... }: # Make sure 'lib' is imported here!

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = false;
      };

      # Force Stylix to back off from the background
      background = lib.mkForce [
        {
          monitor = "";
          path = "${../../assets/wallpapers/girls-last-tour-library.jpg}";
          blur_passes = 2;
          blur_size = 4;
          color = "rgba(25, 20, 20, 1.0)";
        }
      ];

      # Force Stylix to back off from the image
      image = lib.mkForce [
        {
          monitor = "";
          path = "/home/${username}/.face.icon";
          size = 140;
          rounding = 15;
          border_size = 4;
          border_color = "rgba(255, 255, 255, 1.0)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];

      # Force Stylix to back off from the label
      label = lib.mkForce [
        {
          monitor = "";
          text = "$USER";
          color = "rgba(255, 255, 255, 1.0)";
          font_size = 28;
          font_family = "Segoe UI, sans-serif";
          position = "0, -40";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
        }
      ];

      # Force Stylix to back off from the input field
      input-field = lib.mkForce [
        {
          monitor = "";
          size = "220, 35";
          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgba(180, 180, 180, 1.0)";
          inner_color = "rgba(255, 255, 255, 1.0)";
          font_color = "rgba(0, 0, 0, 1.0)";
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
