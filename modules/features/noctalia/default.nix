{
  den,
  inputs,
  ...
}: {
  den.aspects.noctalia = {
    includes = [
      # Required for `screen-shot-and-record` plugin
      den.aspects.utilities.screenshots.satty

      # Required for `slowbongo` plugin
      den.aspects.utilities.evtest

      # https://docs.noctalia.dev/v4/getting-started/nixos/#:~:text=Caution
      den.aspects.settings.networking
      den.aspects.bluetooth
      den.aspects.battery.power-profiles-daemon
      den.aspects.battery.upower
    ];

    nixos = {
      # https://docs.noctalia.dev/v4/getting-started/nixos/?section=binary-cache#binary-cache
      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };
    };

    homeManager = {
      config,
      lib,
      pkgs,
      ...
    }: {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;

        package =
          inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
          (old: {
            postPatch =
              (old.postPatch or "")
              + ''
                # Patch launcher behaviour
                substituteInPlace "Modules/Panels/Launcher/Providers/ApplicationsProvider.qml" \
                  --replace-fail \
                    'CompositorService.spawn(command);' \
                    'Quickshell.execDetached(command);' \
                  --replace-fail \
                    'CompositorService.spawn(app.command);' \
                    'Quickshell.execDetached(app.command);'

                # Patch notification geometry behaviour
                substituteInPlace "Modules/Notification/Notification.qml" \
                  --replace-fail \
                    'readonly property int shadowPadding: Style.shadowBlurMax + Style.marginL' \
                    'readonly property int shadowPadding: 0'

                # substituteInPlace "Modules/Toast/Toast.qml" \
                #   --replace-fail \
                #     'Settings.data.ui.panelBackgroundOpacity' \
                #     '1.0'
              '';
          });

        settings = {
          settingsVersion = 59;
          bar = {
            barType = "framed";
            position = "left";
            monitors = [];
            density = "comfortable";
            showOutline = true;
            showCapsule = true;
            capsuleOpacity = config.stylix.opacity.applications;
            capsuleColorKey = "none";
            widgetSpacing = 6;
            contentPadding = 2;
            fontScale = 1;
            enableExclusionZoneInset = true;
            backgroundOpacity = config.stylix.opacity.applications;
            useSeparateOpacity = true;
            marginVertical = 4;
            marginHorizontal = 4;
            frameThickness = 8;
            frameRadius = 16;
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
                  width = 10;
                }
                {
                  defaultSettings = {
                    enableCross = true;
                    enableWindowsSelection = true;
                    keepSourceScreenshot = false;
                    recordingNotifications = true;
                    recordingSavePath = "~/Videos";
                    savePath = "~/Pictures/Screenshots";
                    screenshotEditor = "satty";
                  };
                  id = "plugin:screen-shot-and-record";
                }
              ];
              center = [
                {
                  defaultSettings = {
                    catColor = "default";
                    catOffsetY = 0;
                    catSize = 1;
                    idleTimeout = 150;
                    raveMode = true;
                    tappyMode = true;
                    useMprisFilter = false;
                    waitingTimeout = 30000;
                  };
                  id = "plugin:slowbongo";
                }
              ];
              right = [
                {
                  hideWhenZero = false;
                  hideWhenZeroUnread = false;
                  iconColor = "none";
                  id = "NotificationHistory";
                  showUnreadBadge = true;
                  unreadBadgeColor = "primary";
                }
                {
                  applyToAllMonitors = false;
                  displayMode = "alwaysHide";
                  iconColor = "none";
                  id = "Brightness";
                  textColor = "none";
                }
                {
                  displayMode = "alwaysHide";
                  iconColor = "none";
                  id = "Volume";
                  middleClickCommand = "pwvucontrol || pavucontrol";
                  textColor = "none";
                }
                {
                  id = "Spacer";
                  width = 10;
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
                  showGpuTemp = true;
                  showLoadAverage = false;
                  showMemoryAsPercent = true;
                  showMemoryUsage = true;
                  showNetworkStats = false;
                  showSwapUsage = false;
                  textColor = "none";
                  useMonospaceFont = true;
                  usePadding = false;
                }
                {
                  id = "Spacer";
                  width = 10;
                }
                {
                  clockColor = "none";
                  customFont = "Maple Mono";
                  formatHorizontal = "HH:mm ddd, MMM dd";
                  formatVertical = "HH mm -- dd MM";
                  id = "Clock";
                  tooltipFormat = "HH:mm ddd, MMM dd";
                  useCustomFont = true;
                }
                {
                  id = "Spacer";
                  width = 10;
                }
                {
                  deviceNativePath = "__default__";
                  displayMode = "icon-only";
                  hideIfIdle = false;
                  hideIfNotDetected = false;
                  id = "Battery";
                  showNoctaliaPerformance = true;
                  showPowerProfiles = true;
                }
              ];
            };
            mouseWheelAction = "none";
            reverseScroll = false;
            mouseWheelWrap = true;
            middleClickAction = "none";
            middleClickFollowMouse = false;
            middleClickCommand = "";
            rightClickAction = "settings";
            rightClickFollowMouse = true;
            rightClickCommand = "";
            screenOverrides = [];
          };
          general = {
            avatarImage = "${inputs.self}/nixconf/assets/wallpapers/avatars/default.png";
            dimmerOpacity = 0.2;
            showScreenCorners = false;
            forceBlackScreenCorners = false;
            scaleRatio = 1;
            radiusRatio = 1;
            iRadiusRatio = 1;
            boxRadiusRatio = 1;
            screenRadiusRatio = 1;
            animationSpeed = 1;
            animationDisabled = false;
            compactLockScreen = false;
            lockScreenAnimations = true;
            lockOnSuspend = true;
            showSessionButtonsOnLockScreen = true;
            showHibernateOnLockScreen = true;
            enableLockScreenMediaControls = true;
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
            lockScreenCountdownDuration = 4000;
            autoStartAuth = false;
            allowPasswordWithFprintd = false;
            clockStyle = "analog";
            clockFormat = "hh
        mm";
            passwordChars = false;
            lockScreenMonitors = [];
            lockScreenBlur = 0.44;
            lockScreenTint = 0.44;
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
            scrollbarAlwaysVisible = true;
            boxBorderEnabled = true;
            panelBackgroundOpacity = config.stylix.opacity.applications;
            translucentWidgets = true;
            panelsAttachedToBar = true;
            settingsPanelMode = "attached";
            settingsPanelSideBarCardStyle = false;
          };
          location = {
            name = "Hanoi";
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
            autoLocate = true;
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
            directory = "${inputs.self}/assets/wallpapers";
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
            panelPosition = "top_center";
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
            terminalCommand = "kitty -e";
            customLaunchPrefixEnabled = false;
            customLaunchPrefix = "";
            viewMode = "list";
            showCategories = true;
            iconMode = "tabler";
            showIconBackground = false;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            enableSessionSearch = true;
            ignoreMouseInput = false;
            screenshotAnnotationTool = "";
            overviewLayer = false;
            density = "default";
          };
          controlCenter = {
            position = "close_to_bar_button";
            diskPath = "/";
            shortcuts = {
              left = [
                {
                  id = "Network";
                }
                {
                  id = "Bluetooth";
                }
                {
                  id = "WallpaperSelector";
                }
              ];
              right = [
                {
                  id = "PowerProfile";
                }
                {
                  id = "NoctaliaPerformance";
                }
                {
                  id = "KeepAwake";
                }
                {
                  id = "NightLight";
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
                enabled = true;
                id = "audio-card";
              }
              {
                enabled = false;
                id = "brightness-card";
              }
              {
                enabled = true;
                id = "weather-card";
              }
              {
                enabled = true;
                id = "media-sysmon-card";
              }
            ];
          };
          systemMonitor = {
            cpuWarningThreshold = 80;
            cpuCriticalThreshold = 90;
            tempWarningThreshold = 80;
            tempCriticalThreshold = 100;
            gpuWarningThreshold = 80;
            gpuCriticalThreshold = 100;
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
            disableWallpaper = false;
            disableDesktopWidgets = true;
          };
          dock = {
            enabled = false;
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
            countdownDuration = 4000;
            position = "bottom_left";
            showHeader = false;
            showKeybinds = true;
            largeButtonsStyle = false;
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
            density = "default";
            monitors = [];
            location = "top_right";
            overlayLayer = true;
            # Patch notification geometry behaviour
            backgroundOpacity = lib.mkForce 1.0;
            respectExpireTimeout = false;
            lowUrgencyDuration = 2;
            normalUrgencyDuration = 4;
            criticalUrgencyDuration = 12;
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
            # Patch notification geometry behaviour
            backgroundOpacity = lib.mkForce 1.0;
            enabledTypes = [
              0
              1
              2
            ];
            monitors = [];
          };
          audio = {
            volumeStep = 5;
            volumeOverdrive = true;
            spectrumFrameRate = 144;
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
            predefinedScheme = "Zenbones";
            darkMode = true;
            schedulingMode = "off";
            manualSunrise = "06:30";
            manualSunset = "18:30";
            generationMethod = "tonal-spot";
            monitorForColors = "";
            syncGsettings = false;
          };
          templates = {
            activeTemplates = [];
            enableUserTheming = false;
          };
          nightLight = {
            enabled = false;
          };
          hooks = {
            enabled = false;
          };
          plugins = {
            autoUpdate = false;
            notifyUpdates = true;
          };
          idle = {
            enabled = false;
          };
          desktopWidgets = {
            enabled = false;
          };
        };
      };
    };
  };
}
