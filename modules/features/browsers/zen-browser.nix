{
  den,
  inputs,
  ...
}: {
  den.aspects.browsers.zen-browser = {
    homeManager = {
      user,
      lib,
      config,
      pkgs,
      ...
    }: {
      # https://zen-browser-flake.nshard.com/
      imports = [inputs.zen-browser.homeModules.beta];

      programs.zen-browser = {
        enable = true;

        setAsDefaultBrowser = true;

        # https://mozilla.github.io/policy-templates/
        policies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisablePocket = true;
        };

        profiles.${user.name} = {
          settings = {
            "zen.workspaces.continue-where-left-off" = true;
            "zen.view.compact.hide-tabbar" = true;
            "zen.urlbar.behavior" = "float";
          };

          mods = [
            "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
            "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
          ];

          search = {
            force = true;
            default = "ddg";

            engines = {
              mynixos = {
                name = "My NixOS";
                urls = [
                  {
                    template = "https://mynixos.com/search?q={searchTerms}";
                    params = [
                      {
                        name = "query";
                        value = "searchTerms";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = ["@nx"];
              };
            };
          };

          bookmarks = {
            force = true;
            settings = [];
          };

          containersForce = true;
          containers = {};

          spacesForce = true;
          spaces = {
            # "General" = {
            #   id = "c6de089c-410d-4206-961d-ab11f988d40a";
            #   position = 1000;
            #   icon = "🏠";
            # };
            # "Work" = {
            #   id = "cdd10fab-4fc5-494b-9041-325e5759195b";
            #   position = 2000;
            #   icon = "💼";
            #   container = 1;
            # };
          };

          pinsForce = true;
          pinsForceAction = "demote";
          pins = {
            # "GitHub" = {
            #   id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
            #   url = "https://github.com";
            #   position = 101;
            # };
          };

          # keyboardShortcutsVersion = 17;
          # keyboardShortcuts = [
          #   {
          #     id = "zen-compact-mode-toggle";
          #     key = "c";
          #     modifiers = {
          #       control = true;
          #       alt = true;
          #     };
          #   }
          #   {
          #     id = "key_quitApplication";
          #     disabled = true;
          #   }
          # ];
        };
      };

      stylix.targets.zen-browser.profileNames =
        lib.optionalAttrs (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
