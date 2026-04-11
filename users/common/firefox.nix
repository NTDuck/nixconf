{
  pkgs,
  username,
  ...
}: {
  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox;

    profiles = {
      ${username} = {
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

        # search = {
        #   force = true;
        #   default = "ddg";
        #   order = [ "searxng" "nix-packages" "nixos-wiki" "ddg" ];

        #   engines = {
        #     searxng = {
        #       urls = [
        #         { template = "https://searx.org/search?q={searchTerms}"; }
        #       ];
        #       icon = "https://searx.org/favicon.ico";
        #       updateInterval = 86400000; # 24h
        #       definedAliases = [ "@searx" ];
        #       suggestUrls = [
        #         { template = "https://searx.org/autosuggest?q={searchTerms}"; }
        #       ];
        #     };

        #     "nix-packages" = {
        #       urls = [
        #         {
        #           template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
        #           params = [
        #             { name = "type"; value = "packages"; }
        #             { name = "query"; value = "{searchTerms}"; }
        #           ];
        #         }
        #       ];
        #       icon = "https://nixos.wiki/favicon.png";
        #       definedAliases = [ "@np" ];
        #     };

        #     "nixos-wiki" = {
        #       urls = [
        #         { template = "https://nixos.wiki/index.php?search={searchTerms}"; }
        #       ];
        #       icon = "https://nixos.wiki/favicon.png";
        #       updateInterval = 86400000;
        #       definedAliases = [ "@nw" ];
        #     };

        #     ddg = {
        #       urls = [
        #         { template = "https://duckduckgo.com/?q={searchTerms}"; }
        #       ];
        #       definedAliases = [ "@ddg" ];
        #     };

        #     # Hide Bing from the UI
        #     bing.metaData.hidden = true;

        #     # Give Google an alias
        #     google.metaData.alias = "@g";
        #   };
        # };
      };
    };
  };

  stylix.targets.firefox.profileNames = ["${username}"];
}
