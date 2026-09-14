{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      lib,
      pkgs,
      ...
    }: let
      # Map power-profiles-daemon ActiveProfile → eDP-1 refresh rate.
      # quiet/power-saver and balanced run at 60 Hz; performance unlocks 165 Hz.
      refreshByProfile = pkgs.writeShellScriptBin "refresh-by-profile" ''
        set -eu
        export PATH="${pkgs.wlr-randr}/bin:$PATH"

        mode_for() {
          case "$1" in
            performance) echo "2560x1600@165.018997" ;;
            *) echo "2560x1600@60.007999" ;;
          esac
        }

        apply() {
          profile="$1"
          mode="$(mode_for "$profile")"
          # Only touch the mode when it actually differs — mode switches blank
          # the panel for a frame, so avoid no-op flips.
          current="$(${pkgs.wlr-randr}/bin/wlr-randr 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP '\d+x\d+ px, \K[\d.]+(?= Hz \(current\))' || true)"
          want="''${mode#@}"
          if [ "$current" = "$want" ]; then
            exit 0
          fi
          ${pkgs.wlr-randr}/bin/wlr-randr --output eDP-1 --mode "$mode"
        }

        # Initial sync with whatever profile is active right now.
        current_profile="$(busctl --system get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP '(?<=")[^"]+(?=")' || echo balanced)"
        apply "$current_profile"

        # Follow profile changes until killed (session lifetime).
        dbus-monitor --system \
          "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='net.hadess.PowerProfiles'" |
          while read -r line; do
            case "$line" in
              *net.hadess.PowerProfiles*) : ;;
              *) continue ;;
            esac
            profile="$(busctl --system get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oP '(?<=")[^"]+(?=")')" || continue
            apply "$profile"
          done
      '';
    in {
      xresources.properties = {
        "Xft.dpi" = 144;
      };

      wayland.windowManager.mango.settings = {
        monitorrule = lib.mkForce [
          "name:^eDP-1$,width:2560,height:1600,refresh:165.019,x:0,y:0,scale:1.5,vrr:1"
          "name:^HDMI-A-1$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-A-2$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-1$,x:1707,y:0,scale:1,vrr:0"
          "name:^HDMI-2$,x:1707,y:0,scale:1,vrr:0"
        ];
      };

      # Refresh rate follows the power profile: 60 Hz on battery/quiet,
      # 165 Hz in performance mode. Lives in the mango session scope so
      # WAYLAND_DISPLAY is set; dies with the session.
      systemd.user.services.refresh-by-profile = {
        Unit = {
          Description = "Map power-profiles-daemon profile to eDP-1 refresh rate";
          PartOf = ["mango-session.target"];
          After = ["mango-session.target"];
        };
        Service = {
          ExecStart = "${refreshByProfile}/bin/refresh-by-profile";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = ["mango-session.target"];
      };
    };
  };
}
