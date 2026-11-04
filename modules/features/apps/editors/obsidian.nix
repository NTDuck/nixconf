{den, ...}: {
  den.aspects.apps.editors.obsidian = {
    homeManager = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        # --in-process-gpu avoids GPU process crash (FATAL:content/browser/gpu/gpu_data_manager_impl_private.cc)
        # on Linux X11 sessions with Intel integrated graphics, which caused a black screen on launch.
        package = pkgs.unstable.obsidian.override {
          commandLineArgs = "--in-process-gpu";
        };

        defaultSettings = {
          appearance = {
            accentColor = "#ffd700";
          };

          themes = [
            {
              name = "Typewriter";
              repo = "crashmoney/obsidian-typewriter";
            }
          ];
        };
      };
    };
  };
}
