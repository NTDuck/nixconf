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
        # package = pkgs.unstable.zen-beta;

        setAsDefaultBrowser = true;

        # The Zen flake exposes `env` specifically for launcher-level variables.
        # Set Wayland/PipeWire here, not only in the compositor session, so
        # WebRTC capture works from desktop entries and terminal launches alike.
        # https://github.com/0xc000022070/zen-browser-flake/blob/main/examples/16-environment-variables.nix
        env = {
          GTK_USE_PORTAL = "1";
          MOZ_ENABLE_WAYLAND = "1";
          XDG_SESSION_TYPE = "wayland";
        };

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
            # WebRTC screen sharing on wlroots compositors goes through
            # xdg-desktop-portal-wlr/PipeWire rather than X11 capture.
            "media.webrtc.capture.allow-pipewire" = true;
            "media.webrtc.camera.allow-pipewire" = true;
            "widget.use-xdg-desktop-portal" = 1;
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "widget.use-xdg-desktop-portal.mime-handler" = 1;
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

          userChrome = ''
            /* Target Zen Browser's vertical tab sidebar layout specifically */
            #zen-sidebar-web-pages,
            .sidebar-panel,
            #sidebar-box,
            #zen-tabs-container {
              font-size: 11px !important; /* Adjust this lower or higher to match your taste */
            }

            /* Optional: Make the sidebar icons shrink slightly to match the smaller text */
            #zen-tabs-container .tab-icon-image,
            #zen-sidebar-web-pages .sidebar-icon {
              transform: scale(0.85) !important;
            }
          '';
        };
      };

      stylix.targets.zen-browser.profileNames =
        lib.optionals (config.stylix.enable or false) ["${user.name}"];
    };
  };
}
