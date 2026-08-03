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
              inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}.sponsorblock
              inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}.ublock-origin
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

        policies.ExtensionSettings = {
          "betterdeepseek@goygoyengine.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/betterdeepseek@goygoyengine.com/latest.xpi";
          };
        };
      };

      stylix.targets.firefox.profileNames =
        lib.optionals (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
