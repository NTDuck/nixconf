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

        policies.ExtensionSettings =
          # https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/04-extensions.nix
          builtins.mapAttrs (_: pluginId: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
            installation_mode = "force_installed";
          }) {
            # https://github.com/EdgeTypE/better-deepseek
            "betterdeepseek@goygoyengine.com" = "better-deepseek";

            # https://github.com/saeedezzati/superpower-chatgpt
            "cjiggdeafkdppmdmlcdpfigbalcgbkpg@fancydino.com" = "superpower-chatgpt";
          };
      };

      stylix.targets.firefox.profileNames =
        lib.optionals (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
