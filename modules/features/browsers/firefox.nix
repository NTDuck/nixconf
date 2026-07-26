{
  den,
  inputs,
  ...
}: {
  den.aspects.browsers.firefox = {
    homeManager = {
      config,
      lib,
      pkgs,
      user,
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
              inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}.firefox-addons.sponsorblock
              inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}.firefox-addons.ublock-origin
            ];

            settings = {
              "browser.tabs.unloadOnLowMemory" = true;

              "browser.startup.page" = 3;

              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
              "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            };
          };
        };
      };

      stylix.targets.firefox.profileNames =
        lib.optionals (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
