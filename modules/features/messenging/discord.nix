{den, ...}: {
  den.aspects.messenging.discord = {
    homeManager = {pkgs, ...}: {
      programs.vesktop = {
        enable = true;
        package = pkgs.unstable.vesktop;

        # https://github.com/Vencord/Vesktop/blob/main/src/shared/settings.d.ts
        settings = {
          discordBranch = "ptb";
          transparencyOption = "mica";
          tray = true;
          minimizeToTray = true;
          autoStartMinimized = false;
          openLinksWithElectron = false;
          staticTitle = true;
          enableMenu = false;
          disableSmoothScroll = false;
          hardwareAcceleration = true;
          hardwareVideoAcceleration = true;
          arRPC = true; # Rich Presence
          appBadge = true;
          enableTaskbarFlashing = true;
          disableMinSize = true;
          clickTrayToShowHide = false;
          customTitleBar = true;

          enableSplashScreen = true;
          splashTheming = true;
          # splashColor = "#ffffff";
          # splashBackground = "#000000";
          splashPixelated = true;

          spellCheckLanguages = []; # TODO Same as i18n

          audio = {
            workaround = false;
            deviceSelect = false;
            granularSelect = false;
            ignoreVirtual = false;
            ignoreDevices = false;
            ignoreInputMedia = false;
            onlySpeakers = false;
            onlyDefaultSpeakers = false;
          };
        };
      };
    };
  };
}
