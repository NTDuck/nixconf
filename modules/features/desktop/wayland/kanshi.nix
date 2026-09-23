# kanshi output-profile daemon (Wayland) — legion's display mirror
# stack (refactored 2026-09-23).
#
# MIRRORING MODEL: compositor-level clone via overlapping outputs. Each
# mirror profile pins the external output at the SAME position as the
# internal panel (0,0) — the wlroots output layout then renders the same
# region on both, exactly like xrandr --same-as on DELL's X11 session.
# The old wl-mirror@.service approach (a fullscreen mirror WINDOW scaled
# onto the external) is gone: no systemd user units, no profile exec
# hooks — kanshi alone applies the clone.
#
# PROFILE MODEL: kanshi re-evaluates profiles on hotplug and applies the
# FIRST one whose output criteria all match. Order matters:
#   1. one mirror-<out> profile per external (fires while that external
#      is plugged — clones eDP-1 onto it);
#   2. the laptop profile (no external criteria — fires when nothing
#      external is connected; it also explicitly disables every
#      external so an unplugged projector can't keep showing a stale
#      framebuffer).
# Position-cloned outputs show the same logical region. eDP-1's logical
# size on legion is 1707x1067 (2560x1600 @ scale 1.5); a 1080p external
# at scale 1 shows that whole region with margin — same "fit" semantics
# the wl-mirror window provided, without the extra process.
{den, ...}: {
  den.aspects.desktop.wayland.kanshi = {
    internalOutput,
    externalOutputs,
  }: {
    homeManager = {pkgs, ...}: let
      # Compositor-level clone: internal panel at (0,0), external ALSO at
      # (0,0) — overlap = mirror. --scale-from's compositor analog is not
      # expressible (kanshi has no region-sampling), but the panel's
      # logical region fits within any external's native mode.
      clonePosition = "0,0";

      mirrorProfile = output: {
        profile.name = "mirror-${output}";
        profile.outputs = [
          {
            criteria = internalOutput;
            status = "enable";
            position = clonePosition;
          }
          {
            criteria = output;
            status = "enable";
            position = clonePosition;
          }
        ];
      };

      # Nothing external connected: internal panel alone, externals off.
      laptopProfile = {
        profile.name = "laptop";
        profile.outputs =
          [
            {
              criteria = internalOutput;
              status = "enable";
              position = clonePosition;
            }
          ]
          ++ map (output: {
            criteria = output;
            status = "disable";
          }) externalOutputs;
      };
    in {
      services.kanshi = {
        enable = true;
        package = pkgs.unstable.kanshi;

        settings =
          map mirrorProfile externalOutputs
          ++ [laptopProfile];
      };
    };
  };
}
