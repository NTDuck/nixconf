# dunst — minimal X11 notification daemon for the DELL spectrwm session,
# replacing mako (2026-09-22). HM module:
# https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/dunst.nix
#
# Colors come from stylix (auto-enabled at stateVersion >= 23.05).
# We only set the non-color knobs here. stylix writes its own
# `global.background`, `frame_color`, etc. — setting them here would
# conflict (last-wins but stylix's values are mkDefault, so explicit
# values here win; the conflict seen during evaluation is from the
# `urgency_*` blocks which stylix also targets). Keeping this aspect
# minimal avoids the conflict.
{den, ...}: {
  den.aspects.desktop.notifications.dunst = {
    homeManager = {pkgs, ...}: {
      services.dunst = {
        enable = true;
        package = pkgs.unstable.dunst;

        settings = {
          global = {
            # Match the spectrwm border_width = 0 aesthetic.
            frame_width = 0;
            # Top-right corner.
            geometry = "0x0-14+14";
            # Stack notifications from the top.
            stack_from = "top";
            # Don't sort — newest on top of the stack.
            sort = false;
            # Indicate urgency with color.
            indicate_hidden = true;
            # Word-wrap long lines.
            word_wrap = true;
            # Padding inside the notification bubble.
            padding = 14;
            # Max notifications on screen.
            notification_limit = 5;
            # Mouse actions.
            mouse_left_click = "do_action, close_current";
            mouse_middle_click = "close_current";
            mouse_right_click = "close_all";
          };

          # Timeouts per urgency level. stylix owns colors; we own timing.
          urgency_low.timeout = 5;
          urgency_normal.timeout = 10;
          urgency_critical.timeout = 0; # sticky
        };
      };
    };
  };
}
