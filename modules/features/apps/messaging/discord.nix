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
      # 2026-11-12 blank-window fix. Symptom: window maps, content never
      # paints (user-visible blank client for hours; GPU-process 1002
      # crash-loop resolved earlier by the /dev/dri coldplug unit). Root
      # cause: BOTH render nodes on this host are NVIDIA (card0/card1 are
      # the 3060 Mobile + 3090, both bound to nvidia — no i915 node), and
      # chromium's GL-on-GBM path over nvidia-drm produces buffers mango
      # (wlroots) does not present. Vulkan presentation demonstrably works
      # on this stack (games render fine; vulkaninfo lists both GPUs), so
      # route chromium through ANGLE/Vulkan instead of GL-GBM:
      # --use-angle=vulkan. Drop this override when the chromium/nvidia
      # GBM path is fixed upstream.
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop.overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/vesktop \
                --add-flags "--use-angle=vulkan"
            '';
        });
      };
    };
  };
}
