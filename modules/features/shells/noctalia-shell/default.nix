{
  den,
  inputs,
  ...
}: {
  den.aspects.shells.noctalia-shell = {
    nixos = {
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;
        settings = {
          settingsVersion = 59;
          bar = {
            barType = "framed";
            position = "left";
            monitors = [];
            density = "default";
            showOutline = false;
            showCapsule = false;
            capsuleOpacity = 0.8;
            capsuleColorKey = "none";
            widgetSpacing = 8;
            contentPadding = 8;
            fontScale = 1;
            enableExclusionZoneInset = true;
            backgroundOpacity = 0.8;
            useSeparateOpacity = false;
            marginVertical = 4;
            marginHorizontal = 4;
            frameThickness = 8;
            frameRadius = 24;
            outerCorners = true;
            hideOnOverview = false;
            displayMode = "always_visible";
            autoHideDelay = 500;
            autoShowDelay = 150;
            showOnWorkspaceSwitch = true;
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
                  useDistroLogo = true;
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Network";
                  textColor = "none";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Bluetooth";
                  textColor = "none";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "VPN";
                  textColor = "none";
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  applyToAllMonitors = false;
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Brightness";
                  textColor = "none";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Volume";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                  textColor = "none";
                }
                {
                  displayMode = "onhover";
                  iconColor = "none";
                  id = "Microphone";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                  textColor = "none";
                }
              ];
              center = [
                {
                  characterCount = 2;
                  colorizeIcons = false;
                  emptyColor = "secondary";
                  enableScrollWheel = true;
                  focusedColor = "primary";
                  followFocusedScreen = false;
                  fontWeight = "bold";
                  groupedBorderOpacity = 1;
                  hideUnoccupied = true;
                  iconScale = 0.8;
                  id = "Workspace";
                  labelMode = "none";
                  occupiedColor = "secondary";
                  pillSize = 0.6;
                  showApplications = false;
                  showApplicationsHover = false;
                  showBadge = true;
                  showLabelsOnlyWhenOccupied = true;
                  unfocusedIconsOpacity = 1;
                }
              ];
              right = [
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = true;
                  iconColor = "none";
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  deviceNativePath = "__default__";
                  displayMode = "graphic-clean";
                  hideIfIdle = false;
                  hideIfNotDetected = true;
                  id = "Battery";
                  showNoctaliaPerformance = false;
                  showPowerProfiles = false;
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  compactMode = true;
                  diskPath = "/";
                  iconColor = "none";
                  id = "SystemMonitor";
                  showCpuCores = false;
                  showCpuFreq = false;
                  showCpuTemp = true;
                  showCpuUsage = true;
                  showDiskAvailable = false;
                  showDiskUsage = false;
                  showDiskUsageAsPercent = false;
                  showGpuTemp = false;
                  showLoadAverage = false;
                  showMemoryAsPercent = false;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  showSwapUsage = false;
                  textColor = "none";
                  useMonospaceFont = true;
                  usePadding = false;
                }
                {
                  id = "Spacer";
                  width = 20;
                }
                {
                  clockColor = "none";
                  customFont = "Maple Mono";
                  formatHorizontal = "HH:mm:ss";
                  formatVertical = "HH mm ss";
                  id = "Clock";
                  tooltipFormat = "";
                  useCustomFont = true;
                }
              ];
            };
            mouseWheelAction = "workspace";
            reverseScroll = false;
            mouseWheelWrap = true;
            middleClickAction = "controlCenter";
            middleClickFollowMouse = false;
            middleClickCommand = "";
            rightClickAction = "controlCenter";
            rightClickFollowMouse = true;
            rightClickCommand = "";
            screenOverrides = [];
          };
          general = {
            avatarImage = "${inputs.self}/assets/wallpapers/avatars/default.png";
            dimmerOpacity = 0.2;
            showScreenCorners = false;
            forceBlackScreenCorners = false;
            scaleRatio = 1.0;
            radiusRatio = 1;
            iRadiusRatio = 1;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1.25;
            animationDisabled = false;
            compactLockScreen = false;
            lockScreenAnimations = false;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            showHibernateOnLockScreen = false;
            enableLockScreenMediaControls = false;
            enableShadows = true;
            enableBlurBehind = true;
            shadowDirection = "center";
            shadowOffsetX = 0;
            shadowOffsetY = 0;
            language = "";
            allowPanelsOnScreenWithoutBar = true;
            showChangelogOnStartup = true;
            telemetryEnabled = false;
            enableLockScreenCountdown = true;
            lockScreenCountdownDuration = 8000;
            autoStartAuth = false;
            allowPasswordWithFprintd = false;
            clockStyle = "analog";
            clockFormat = "hh
                mm";
            passwordChars = false;
            lockScreenMonitors = [];
            lockScreenBlur = 0.32;
            lockScreenTint = 0;
            keybinds = {
              keyUp = [
                "Up"
              ];
              keyDown = [
                "Down"
              ];
              keyLeft = [
                "Left"
              ];
              keyRight = [
                "Right"
              ];
              keyEnter = [
                "Return"
                "Enter"
              ];
              keyEscape = [
                "Esc"
              ];
              keyRemove = [
                "Del"
              ];
            };
            reverseScroll = false;
            smoothScrollEnabled = true;
          };
          ui = {
            fontDefault = "Inter";
            fontFixed = "Maple Mono";
            fontDefaultScale = 1;
            fontFixedScale = 1;
            tooltipsEnabled = true;
            scrollbarAlwaysVisible = false;
            boxBorderEnabled = true;
            panelBackgroundOpacity = 0.8;
            translucentWidgets = true;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            settingsPanelSideBarCardStyle = false;
          };
          location = {
            name = "Hanoi, Vietnam";
            weatherEnabled = true;
            weatherShowEffects = true;
            weatherTaliaMascotAlways = false;
            useFahrenheit = false;
            use12hourFormat = false;
            showWeekNumberInCalendar = true;
            showCalendarEvents = true;
            showCalendarWeather = true;
            analogClockInCalendar = true;
            firstDayOfWeek = -1;
            hideWeatherTimezone = false;
            hideWeatherCityName = false;
            autoLocate = false;
          };
          calendar = {
            cards = [
              {
                enabled = true;
                id = "calendar-header-card";
              }
              {
                enabled = true;
                id = "calendar-month-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };
          wallpaper = {
            enabled = true;
            overviewEnabled = false;
            directory = "/home/ayin/Pictures/Wallpapers";
            monitorDirectories = [];
            enableMultiMonitorDirectories = false;
            showHiddenFiles = false;
            viewMode = "single";
            setWallpaperOnAllMonitors = true;
            linkLightAndDarkWallpapers = true;
            fillMode = "crop";
            fillColor = "#000000";
            useSolidColor = false;
            solidColor = "#1a1a2e";
            automationEnabled = false;
            wallpaperChangeMode = "random";
            randomIntervalSec = 300;
            transitionDuration = 1500;
            transitionType = [
              "fade"
              "disc"
              "stripes"
              "wipe"
              "pixelate"
              "honeycomb"
            ];
            skipStartupTransition = false;
            transitionEdgeSmoothness = 0.05;
            panelPosition = "follow_bar";
            hideWallpaperFilenames = false;
            useOriginalImages = false;
            overviewBlur = 0.4;
            overviewTint = 0.6;
            useWallhaven = false;
            wallhavenQuery = "";
            wallhavenSorting = "relevance";
            wallhavenOrder = "desc";
            wallhavenCategories = "111";
            wallhavenPurity = "100";
            wallhavenRatios = "";
            wallhavenApiKey = "";
            wallhavenResolutionMode = "atleast";
            wallhavenResolutionWidth = "";
            wallhavenResolutionHeight = "";
            sortOrder = "name";
            favorites = [];
          };
          appLauncher = {
            enableClipboardHistory = false;
            autoPasteClipboard = false;
            enableClipPreview = true;
            clipboardWrapText = true;
            enableClipboardSmartIcons = true;
            enableClipboardChips = true;
            clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
            clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
            position = "bottom_center";
            pinnedApps = [];
            sortByMostUsed = true;
            terminalCommand = "";
            customLaunchPrefixEnabled = false;
            customLaunchPrefix = "";
            viewMode = "list";
            showCategories = false;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            enableSessionSearch = true;
            ignoreMouseInput = false;
            screenshotAnnotationTool = "";
            overviewLayer = false;
            density = "compact";
          };
          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                {
                  id = "AirplaneMode";
                }
                {
                  id = "Bluetooth";
                }
                {
                  id = "DarkMode";
                }
              ];
              right = [
                {
                  id = "Notifications";
                }
                {
                  id = "PowerProfile";
                }
                {
                  id = "Network";
                }
              ];
            };
            cards = [
              {
                enabled = true;
                id = "profile-card";
              }
              {
                enabled = true;
                id = "shortcuts-card";
              }
              {
                enabled = false;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = false;
                id = "media-sysmon-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
            ];
          };
          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 90;
            gpuWarningThreshold = 80;
            gpuCriticalThreshold = 90;
            memWarningThreshold = 80;
            memCriticalThreshold = 90;
            swapWarningThreshold = 80;
            swapCriticalThreshold = 90;
            diskWarningThreshold = 80;
            diskCriticalThreshold = 90;
            diskAvailWarningThreshold = 20;
            diskAvailCriticalThreshold = 10;
            batteryWarningThreshold = 20;
            batteryCriticalThreshold = 5;
            enableDgpuMonitoring = true;
            useCustomColors = false;
            warningColor = "";
            criticalColor = "";
            externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          };
          noctaliaPerformance = {
            disableWallpaper = true;
            disableDesktopWidgets = true;
          };
          dock = {
            enabled = false;
            position = "bottom";
            displayMode = "auto_hide";
            dockType = "floating";
            backgroundOpacity = 0.8;
            floatingRatio = 1;
            size = 1;
            onlySameOutput = true;
            monitors = [];
            pinnedApps = [];
            colorizeIcons = false;
            showLauncherIcon = false;
            launcherPosition = "end";
            launcherUseDistroLogo = false;
            launcherIcon = "";
            launcherIconColor = "none";
            pinnedStatic = false;
            inactiveIndicators = false;
            groupApps = false;
            groupContextMenuMode = "extended";
            groupClickAction = "cycle";
            groupIndicatorStyle = "dots";
            deadOpacity = 0.6;
            animationSpeed = 1;
            sitOnFrame = false;
            showDockIndicator = false;
            indicatorThickness = 3;
            indicatorColor = "primary";
            indicatorOpacity = 0.6;
          };
          network = {
            bluetoothRssiPollingEnabled = false;
            bluetoothRssiPollIntervalMs = 60000;
            networkPanelView = "wifi";
            wifiDetailsViewMode = "grid";
            bluetoothDetailsViewMode = "grid";
            bluetoothHideUnnamedDevices = false;
            disableDiscoverability = false;
            bluetoothAutoConnect = true;
          };
          sessionMenu = {
            enableCountdown = true;
            countdownDuration = 10000;
            position = "center";
            showHeader = true;
            showKeybinds = true;
            largeButtonsStyle = true;
            largeButtonsLayout = "single-row";
            powerOptions = [
              {
                action = "lock";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "1";
              }
              {
                action = "suspend";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "2";
              }
              {
                action = "hibernate";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "3";
              }
              {
                action = "reboot";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "4";
              }
              {
                action = "logout";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "5";
              }
              {
                action = "shutdown";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "6";
              }
              {
                action = "rebootToUefi";
                command = "";
                countdownEnabled = true;
                enabled = true;
                keybind = "7";
              }
              {
                action = "userspaceReboot";
                command = "";
                countdownEnabled = true;
                enabled = false;
                keybind = "";
              }
            ];
          };
          notifications = {
            enabled = true;
            enableMarkdown = false;
            density = "compact";
            monitors = [];
            location = "top_right";
            overlayLayer = true;
            backgroundOpacity = 0.8;
            respectExpireTimeout = false;
            lowUrgencyDuration = 4;
            normalUrgencyDuration = 4;
            criticalUrgencyDuration = 8;
            clearDismissed = true;
            saveToHistory = {
              low = true;
              normal = true;
              critical = true;
            };
            sounds = {
              enabled = false;
              volume = 0.5;
              separateSounds = false;
              criticalSoundFile = "";
              normalSoundFile = "";
              lowSoundFile = "";
              excludedApps = "discord,firefox,chrome,chromium,edge";
            };
            enableMediaToast = false;
            enableKeyboardLayoutToast = true;
            enableBatteryToast = true;
          };
          osd = {
            enabled = true;
            location = "top_right";
            autoHideMs = 2000;
            overlayLayer = true;
            backgroundOpacity = 0.8;
            enabledTypes = [
              0
              1
              2
            ];
            monitors = [];
          };
          audio = {
            volumeStep = 5;
            volumeOverdrive = false;
            spectrumFrameRate = 30;
            visualizerType = "linear";
            spectrumMirrored = true;
            mprisBlacklist = [];
            preferredPlayer = "";
            volumeFeedback = false;
            volumeFeedbackSoundFile = "";
          };
          brightness = {
            brightnessStep = 5;
            enforceMinimum = false;
            enableDdcSupport = false;
            backlightDeviceMappings = [];
          };
          colorSchemes = {
            useWallpaperColors = false;
            predefinedScheme = "Monochrome";
            darkMode = true;
            schedulingMode = "off";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "tonal-spot";
            monitorForColors = "";
            syncGsettings = true;
          };
          templates = {
            activeTemplates = [];
            enableUserTheming = false;
          };
          nightLight = {
            enabled = false;
            forced = false;
            autoSchedule = true;
            nightTemp = "4000";
            dayTemp = "6500";
            manualSunrise = "06:30";
            manualSunset = "18:30";
          };
          hooks = {
            enabled = false;
            wallpaperChange = "";
            darkModeChange = "";
            screenLock = "";
            screenUnlock = "";
            performanceModeEnabled = "";
            performanceModeDisabled = "";
            startup = "";
            session = "";
            colorGeneration = "";
          };
          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
          };
          idle = {
            enabled = false;
            screenOffTimeout = 600;
            lockTimeout = 660;
            suspendTimeout = 1800;
            fadeDuration = 5;
            screenOffCommand = "";
            lockCommand = "";
            suspendCommand = "";
            resumeScreenOffCommand = "";
            resumeLockCommand = "";
            resumeSuspendCommand = "";
            customCommands = "[]";
          };
          desktopWidgets = {
            enabled = false;
            overviewEnabled = true;
            gridSnap = false;
            gridSnapScale = false;
            monitorWidgets = [];
          };
        };
      };
    };
  };
}
