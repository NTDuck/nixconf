{ pkgs, ... }:

let
  wayout-script = pkgs.writeShellScriptBin "wayout-script" ''
    while true; do
      # 1. Get Battery (Intel HD 520 path)
      BAT=$(cat /sys/class/power_supply/BAT0/capacity)

      # 2. Get Time
      TIME=$(date +'%H:%M')

      # 3. Get Active Workspace (Parsed for your Greek Symbols)
      # This uses swaymsg to find the focused workspace name
      WS=$(${pkgs.sway}/bin/swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | select(.focused).name')

      # Output the line to wayout
      echo "<span color='#8be9fd'>$WS</span> | <span color='#50fa7b'>$BAT%</span> | $TIME"

      # Poll every 30 seconds to save battery on the i7-6600U
      sleep 30
  '';
in
{
  home.packages = [
    pkgs.wayout
    pkgs.jq
    wayout-script
  ];

  systemd.user.services.wayout-bar = {
    Unit = {
      Description = "Wayout Minimalist Bar";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      # We pipe the script directly into wayout
      ExecStart = "${pkgs.bash}/bin/bash -c '${status-script}/bin/wayout-status | ${pkgs.wayout}/bin/wayout --edge left --width 32 --feed-line --font \"JetBrainsMono Nerd Font 10\"'";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
