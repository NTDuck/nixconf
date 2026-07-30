{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {lib, ...}: {
      programs.noctalia-shell.settings = lib.mapAttrsRecursive (_: value: lib.mkForce value) {
        bar = {
          showOutline = false;
          showCapsule = false;
          capsuleOpacity = 1.0;
          widgetSpacing = 2;
          contentPadding = 0;
          backgroundOpacity = 1.0;
          useSeparateOpacity = false;
          marginVertical = 0;
          marginHorizontal = 0;
          frameThickness = 0;
          frameRadius = 0;
          outerCorners = false;
          showOnWorkspaceSwitch = false;

          # Keep only continuously useful, inexpensive widgets.
          widgets = {
            left = [
              {
                colorizeDistroLogo = false;
                colorizeSystemIcon = "none";
                colorizeSystemText = "none";
                customIconPath = "";
                enableColorization = false;
                icon = "noctalia";
                id = "ControlCenter";
                useDistroLogo = false;
              }
            ];

            center = [];

            right = [
              {
                clockColor = "none";
                customFont = "Maple Mono";
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                tooltipFormat = "HH:mm";
                useCustomFont = true;
              }
              {
                deviceNativePath = "__default__";
                displayMode = "icon-only";
                hideIfIdle = false;
                hideIfNotDetected = false;
                id = "Battery";
                showNoctaliaPerformance = false;
                showPowerProfiles = true;
              }
            ];
          };
        };

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

        calendar.cards = [
          {
            enabled = true;
            id = "calendar-header-card";
          }
          {
            enabled = true;
            id = "calendar-month-card";
          }
          {
            enabled = false;
            id = "weather-card";
          }
        ];

        wallpaper = {
          enabled = false;
          overviewEnabled = false;
          automationEnabled = false;
          skipStartupTransition = true;
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
