# bemenu-run application launcher.
#
# Extracted from the labwc aspect (2026-09-20) as a swappable feature, like
# panels/notifications. SCOPE: package + fonts only. The W-d KEYBIND stays
# in the labwc aspect — den's aspect-content merge is last-wins for
# function-valued class defs, so a second homeManager module here would
# REPLACE the labwc aspect's keybind list instead of extending it
# (verified 2026-09-20: rc.keybind collapsed to length 1).
#
# "--prefix '$'": single-character prompt prefix rendered before the query
# line — the launcher reads as a shell-ish command bar (matches the
# powerlevel10k prompt from the desktop shells aspect). The labwc keybind
# passes the same flag so the prompt survives whichever file is edited.
{
  den.aspects.desktop.launchers.bemenu = {
    homeManager = {
      pkgs,
      ...
    }: {
      home.packages = [
        pkgs.unstable.bemenu
      ];
    };
  };
}
