{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {lib, ...}: {
      # Override for performance
      programs.noctalia.settings = lib.mapAttrsRecursive (_: value: lib.mkForce value) {
        general = {
          dimmerOpacity = 0.0;
          animationDisabled = true;
          lockScreenAnimations = false;
          enableShadows = false;
          enableBlurBehind = false;
          showChangelogOnStartup = false;
          lockScreenBlur = 0.0;
          smoothScrollEnabled = false;
        };

        ui = {
          tooltipsEnabled = false;
          scrollbarAlwaysVisible = false;
          boxBorderEnabled = false;
          panelBackgroundOpacity = 1.0;
          translucentWidgets = false;
        };

        location = {
          weatherEnabled = false;
          weatherShowEffects = false;
          showCalendarEvents = false;
          showCalendarWeather = false;
          analogClockInCalendar = false;
          autoLocate = false;
        };

        appLauncher = {
          enableClipPreview = false;
          enableClipboardSmartIcons = false;
          enableClipboardChips = false;
          showCategories = false;
          showIconBackground = false;
          overviewLayer = false;
        };

        systemMonitor.enableDgpuMonitoring = false;

        notifications = {
          backgroundOpacity = 1.0;
          enableMediaToast = false;
          enableKeyboardLayoutToast = false;
          enableBatteryToast = false;
        };

        osd.backgroundOpacity = 1.0;

        audio = {
          spectrumFrameRate = 30;
          spectrumMirrored = false;
        };

        plugins = {
          autoUpdate = false;
          notifyUpdates = false;
        };

        desktopWidgets.enabled = false;
        dock.enabled = false;
      };
    };
  };
}
