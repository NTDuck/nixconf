{
  config,
  lib,
  self,
  ...
}: let
  colors = config.lib.stylix.colors.withHashtag;
in {
  programs.gtklock = {
    enable = true;
    config = {
      main = {
        time-format = "%H:%M:%S";
      };
    };

    style = lib.mkForce ''
      window {
        background-image: linear-gradient(rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8)), url("${self}/assets/wallpapers/girls-last-tour-library.jpg");
        background-size: cover;
        background-repeat: no-repeat;
        background-position: center;
      }

      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        color: ${colors.base05};
        border-radius: 0px;
        box-shadow: none;
        text-shadow: none;
      }

      #clock-label {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 72px;
        font-weight: 200;
        margin-bottom: 10px;
        color: ${colors.base0B};
      }

      #date-label {
        font-size: 0px;
        margin: 0px;
        color: transparent;
      }

      #input-label {
        font-size: 0px;
        margin: 0px;
        color: transparent;
      }

      entry {
        background-color: rgba(0, 0, 0, 0.5);
        border: 1px solid ${colors.base0B};
        color: ${colors.base05};
        font-size: 20px;
        padding: 10px 20px;
        caret-color: ${colors.base05};
        min-width: 300px;

        letter-spacing: 4px;
        border-radius: 4px;
      }

      entry:focus {
        border: 2px solid ${colors.base0B};
        background-color: rgba(0, 0, 0, 0.8);
      }

      #warning-label {
        color: ${colors.base08};
        font-size: 18px;
        margin-top: 20px;
      }

      #unlock-button {
        background: transparent;
        color: transparent;
        border: none;
        margin: 0;
        padding: 0;
        min-height: 0;
        min-width: 0;
        font-size: 0;
      }

      entry image {
        color: transparent;
        background: transparent;
        opacity: 0;
      }
    '';
  };
}
