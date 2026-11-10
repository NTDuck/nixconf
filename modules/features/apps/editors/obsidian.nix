{den, ...}: {
  den.aspects.apps.editors.obsidian = {
    homeManager = {pkgs, ...}: {
      programs.obsidian = {
        enable = true;
        # --disable-gpu (2026-11-10): the prior --in-process-gpu (added for
        # a GPU-process black screen on Intel iGPU X11) now segfaults the
        # whole app — kernel log: `traps: Chrome_InProcGp general
        # protection fault ... in libgbm.so.1.0.0` — Mesa GBM derefs a
        # null buffer after an EGL_BAD_ALLOC loop (684 eglCreateImage
        # 0x3003 errors in a 12s launch). In-process mode routes that
        # broken gbm path into the main process, so the GPF kills
        # everything. No-flag also hits the EGL loop (GPU init is broken
        # on this host regardless); --disable-gpu skips GPU init entirely
        # and launches clean (0 EGL errors, no traps, 20s soak).
        package = pkgs.unstable.obsidian.override {
          commandLineArgs = "--disable-gpu";
        };

        # Obsidian CLI (obsidian-cli, ships in the same package): writes
        # cli=true into ~/.config/obsidian/obsidian.json so the CLI can
        # talk to a running Obsidian over ~/.obsidian-cli.sock (verified
        # 2026-11-10: `obsidian-cli --help` lists the full command set
        # once the flag is on; without it the CLI exits with "Command
        # line interface is not enabled").
        cli.enable = true;

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
