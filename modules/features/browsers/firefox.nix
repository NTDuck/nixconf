{den, ...}: {
  den.aspects.browsers.firefox = {
    homeManager = {
      user,
      lib,
      config,
      pkgs,
      ...
    }: {
      programs.firefox = {
        enable = true;
        package = pkgs.unstable.firefox;

        profiles = {
          ${user.name} = {
            isDefault = true;

            extensions.force = true;

            extensions.packages = [
              pkgs.nur.repos.rycee.firefox-addons.sponsorblock
              pkgs.nur.repos.rycee.firefox-addons.ublock-origin
            ];

            settings = {
              "media.av1.enabled" = false;
              "media.ffmpeg.vaapi.enabled" = true;
              "media.hardware-video-decoding.force-enabled" = true;

              "gfx.webrender.all" = true;
              "layers.acceleration.force-enabled" = true;

              "dom.suspend_inactive.enabled" = true;
              "browser.tabs.unloadOnLowMemory" = true;

              "datareporting.healthreport.uploadEnabled" = false;
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.server" = "data:,";

              "browser.startup.page" = 2;
              "browser.zoom.siteSpecific" = true;

              "network.cookie.lifetimePolicy" = 0;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown.siteSettings" = false;
              "privacy.sanitize.sanitizeOnShutdown" = false;

              "privacy.resistFingerprinting" = false;

              "browser.urlbar.autoFill" = true;
              "browser.urlbar.dnsFirstForSingleWords" = true;

              "browser.urlbar.suggest.history" = true;
              "browser.urlbar.suggest.bookmark" = true;
              "browser.urlbar.suggest.openpage" = true;
              "browser.urlbar.suggest.searches" = true;

              "browser.search.suggest.enabled" = true;

              "signon.rememberSignons" = false;
              "passwordmanager.enabled" = false;

              "browser.tabs.firefox-view" = false;

              "extensions.pocket.enabled" = false;

              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
              "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
              "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
              "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
            };
          };
        };
      };

      stylix.targets.firefox.profileNames =
        lib.optionalAttrs (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
