{ pkgs, lib, ... }:

{
  programs.gtklock = {
    enable = true;
    package = pkgs.gtklock;

    config = {
      main = {
        time-format = "%H:%M";

        # To enable modules later, you would add them here like this:
        # modules = "${pkgs.gtklock-userinfo-module}/lib/gtklock/userinfo.so;${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar.so";
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
        color: #00FF00;
        border-radius: 0px;
        box-shadow: none;
        text-shadow: none;
      }

      #clock-label {
        font-size: 72px;
        font-weight: 900;
        margin-bottom: 10px;
      }

      #date-label {
        font-size: 24px;
        margin-bottom: 60px;
      }

      entry {
        background-color: rgba(0, 0, 0, 0.5);
        border: 1px solid #00FF00;
        color: #00FF00;
        font-size: 20px;
        padding: 10px 20px;
        caret-color: #00FF00;
        min-width: 300px;
      }

      entry:focus {
        border: 2px solid #00FF00;
        background-color: rgba(0, 0, 0, 0.8);
      }

      #warning-label {
        color: #FF0000;
        font-size: 18px;
        margin-top: 20px;
      }
    '';
  };
}
