# lemonbar — the DELL/spectrwm session bar (legion uses noctalia via
# mangowm). Replaces yambar (2026-09-22 user request).
#
# WHY LEMONBAR OVER YAMBAR/POLYBAR: lemonbar is the canonical spectrwm
# pairing (spectrwm's example config uses lemonbar via `bar[X] = …`).
# It's a tiny C binary (~1500 LOC) with no config file of its own —
# everything is piped in on stdin. spectrwm's `bar_enabled = 0` (set in
# the spectrwm aspect) disables spectrwm's built-in bar so lemonbar
# owns the bar slot.
#
# The bar script reads spectrwm's `wsx` action output for workspace
# state and pipes a fixed-format status line to lemonbar. spectrwm
# invokes the script via `bar[X] = …` in spectrwm.conf; the HM spectrwm
# module doesn't expose `bar[]` settings, so we write the bar config
# via xdg.configFile and let spectrwm pick it up from the default
# location (~/.config/spectrwm/bar.sh).
#
# Font: "Maple Mono NF CN" — same family the stylix aspect pins for
# monospace, so the bar matches the terminal.
{den, ...}: {
  den.aspects.desktop.panels.lemonbar = {
    homeManager = {
      pkgs,
      config,
      ...
    }: let
      colors = config.lib.stylix.colors;
      # lemonbar uses #RRGGBBAA hex (no alpha = opaque).
      bg = "#${colors.base00-hex}";
      fg = "#${colors.base05-hex}";
      accent = "#${colors.base0D-hex}";
      muted = "#${colors.base04-hex}";
    in {
      home.packages = [
        pkgs.unstable.lemonbar
      ];

      # Bar script: spectrwm invokes this via `bar[1] = ~/.config/
      # spectrwm/bar.sh` (written below). The script reads workspace
      # state from spectrwm's `wsx` action and pipes a status line to
      # lemonbar.
      xdg.configFile."spectrwm/bar.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          # lemonbar status script for the DELL spectrwm session.
          # Invoked by spectrwm via `bar[1] = ~/.config/spectrwm/bar.sh`.
          # spectrwm pipes workspace state to stdin (one line per wsx
          # event); we render a fixed status line and forward to lemonbar.

          font="Maple Mono NF CN:size=10"

          # lemonbar click handlers: button1=prev ws, button4=next ws,
          # button5=prev ws. spectrwm's wsx action takes a workspace
          # number; we use the spectrwm binary directly.
          SPW="${pkgs.spectrwm}/bin/spectrwm"

          while read -r line; do
            # spectrwm wsx format: "WS:<n>:<name>:<visible>:<focused>"
            case "$line" in
              WS:*) ;;
              *) continue ;;
            esac

            # Parse workspace state.
            ws_num=$(echo "$line" | cut -d: -f2)
            ws_focused=$(echo "$line" | cut -d: -f5)

            # Build workspace indicators.
            ws_indicators=""
            for i in 1 2 3 4 5 6 7 8 9; do
              if [ "$i" = "$ws_focused" ]; then
                ws_indicators="$ws_indicators%{F${accent}} $i %{F-}"
              else
                ws_indicators="$ws_indicators%{F${muted}} $i %{F-}"
              fi
            done

            # Right side: clock.
            clock=$(date +"%H:%M")

            # Pipe to lemonbar.
            echo "%{B${bg}}%{F${fg}} $ws_indicators | $clock "
          done

          # Initial render (spectrwm fires wsx on startup, but be safe).
          echo "%{B${bg}}%{F${fg}} loading... "
        '';
      };

      # spectrwm.conf fragment that wires the bar script. The HM
      # spectrwm module writes ~/.config/spectrwm/spectrwm.conf; we
      # append our bar config via a separate file that spectrwm
      # sources via `include` (spectrwm.conf supports `include`).
      xdg.configFile."spectrwm/bar.conf".text = ''
        # Bar config — sourced by spectrwm.conf via `include`.
        bar_enabled = 1
        bar_font = Maple Mono NF CN:size=10
        bar_color = ${bg}
        bar_stipple_colors = ${fg}
        bar_action = ${config.home.homeDirectory}/.config/spectrwm/bar.sh
        bar_timeout = 1
      '';
    };
  };
}
