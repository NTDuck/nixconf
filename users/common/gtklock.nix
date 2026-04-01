{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.unstable.gtklock
  ];

  xdg.configFile."gtklock/config.ini".text = ''
    [main]
    time-format="%H:%M:%S"
    style=${"~"}/.config/gtklock/style.css
  '';

  xdg.configFile."gtklock/style.css".text = lib.mkForce ''
    window {
      background-color: #000000;
    }

    * {
      font-family: "JetBrainsMono Nerd Font", monospace;
      color: #00FF00; /* Terminal Green */
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
      background-color: #000000;
      border: 1px solid #00FF00;
      color: #00FF00;
      font-size: 20px;
      padding: 10px 20px;
      caret-color: #00FF00;
      min-width: 300px;
    }

    entry:focus {
      border: 2px solid #00FF00;
      background-color: #0a0a0a;
    }

    #warning-label {
      color: #FF0000;
      font-size: 18px;
      margin-top: 20px;
    }
  '';
}
