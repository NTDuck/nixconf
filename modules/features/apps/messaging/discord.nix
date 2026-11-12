{den, ...}: {
  den.aspects.apps.messaging.discord = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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
      # stylix autoEnable re-introduced the read-only vencord
      # settings/settings.json symlink AFTER the removal above (its
      # vesktop target ships enabledThemes=["stylix.css"]) — EROFS again
      # on every launch. Disabled here: the symlink is the wrong shape for
      # vesktop's self-mutating settings, and the theme was invisible
      # anyway while the client rendered blank.
      stylix.targets.vesktop.enable = false;
      # 2026-11-12 blank-window fix, second attempt. First attempt
      # (--use-angle=vulkan) was wrong: chromium logs
      # "'--ozone-platform=wayland' is not compatible with Vulkan. Consider
      # switching to '--ozone-platform=x11' or disabling Vulkan" — the
      # flag never engaged, ANGLE init failed, window stayed blank.
      # Root cause stands: both render nodes are NVIDIA; chromium's
      # GL-on-GBM over nvidia-drm under native Wayland produces buffers
      # mango (wlroots) does not present (and mesa dri loading hits the
      # chromium sandbox). Empirically clean run: --ozone-platform=x11
      # (XWayland) + --use-angle=gl — gpu-process starts with zero GL
      # errors, vs hard failures for vulkan on both ozones. Drop this
      # override when the chromium/nvidia Wayland-GBM path works upstream.
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop.overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/vesktop \
                --add-flags "--ozone-platform=x11 --use-angle=gl"
            '';
        });
      };
    };
  };
}
