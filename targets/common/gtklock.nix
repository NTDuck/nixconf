{ config, pkgs, lib, ... }: # Make sure 'config' is added here!

let
  # Grab the hex colors from your current Stylix theme
  colors = config.lib.stylix.colors.withHashtag;
in
{
  programs.gtklock = {
    enable = true;
    package = pkgs.gtklock;

    config = {
      main = {
        time-format = "%H:%M";
      };
    };

    style = lib.mkForce ''
      /* Sway Background with an 80% (0.8) opaque black overlay */
      window {
        background-image: linear-gradient(rgba(0, 0, 0, 0.8), rgba(0, 0, 0, 0.8)), url("${../../assets/wallpapers/girls-last-tour-library.jpg}");
        background-size: cover;
        background-repeat: no-repeat;
        background-position: center;
      }

      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        color: ${colors.base05}; /* Default Foreground */
        border-radius: 0px;
        box-shadow: none;
        text-shadow: none;
      }

      #clock-label {
        font-size: 72px;
        font-weight: 900;
        margin-bottom: 10px;
        color: ${colors.base0B}; /* Theme Accent/Green */
      }

      #date-label {
        font-size: 24px;
        margin-bottom: 60px;
        color: ${colors.base0B}; /* Theme Accent/Green */
      }

      entry {
        background-color: rgba(0, 0, 0, 0.5);
        border: 1px solid ${colors.base0B};
        color: ${colors.base05};
        font-size: 20px;
        padding: 10px 20px;
        caret-color: ${colors.base05};
        min-width: 300px;
      }

      entry:focus {
        border: 2px solid ${colors.base0B};
        background-color: rgba(0, 0, 0, 0.8);
      }

      #warning-label {
        color: ${colors.base08}; /* Theme Red/Error */
        font-size: 18px;
        margin-top: 20px;
      }

      /* * Hides the "Unlock" button by shrinking it to 0
       * and making it transparent (GTK3 CSS doesn't support display: none)
       */
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

      /* Hides the reveal-password 'eye' icon inside the text entry */
      entry image {
        color: transparent;
        background: transparent;
      }
    '';
  };
}
