{den, ...}: {
  den.aspects.apps.messaging.discord = {
    homeManager = {pkgs, ...}: {
      # User's GUI choice (2026-09-15): discord:// links open Vesktop.
      xdg.mimeApps.defaultApplications."x-scheme-handler/discord" = ["vesktop.desktop"];
      # 2026-11-12: programs.vesktop.settings / vencord.settings REMOVED
      # deliberately. The HM module writes both as read-only store symlinks
      # (~/.config/vesktop/settings.json and settings/settings.json), but
      # vesktop self-mutates both at runtime (renderer settings, window
      # state, plugin state) — every launch hit EROFS on the write. The two
      # files are now plain user-owned files, seeded 2026-11-12 from the
      # declarative content below (preserved in git history at this
      # commit). Do NOT re-add the HM settings blocks; re-seed by hand if
      # needed.
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop;
      };
    };
  };
}
