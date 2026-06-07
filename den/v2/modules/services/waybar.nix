{
  flake.modules.homeManager.waybar = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "left";
          margin-top = 4;
          margin-bottom = 4;
          margin-left = 4;

          modules-left = [
            "sway/workspaces"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "pulseaudio"
            "backlight"
            "battery"
            "network"
            "cpu"
            "memory"
            "temperature"
          ];

          "sway/workspaces" = {
            disable-scroll = true;
            format = "{icon}{name} ";
            format-icons = {
              focused = "*";
              default = " ";
            };
          };

          "pulseaudio" = {
            format = "VOL
{volume:03d}%";
            format-muted = "MUT
{volume:03d}%";
            tooltip = false;
          };

          "backlight" = {
            format = "LGT
{percent:03d}%";
            tooltip = false;
          };

          "network" = {
            format-wifi = "WIF
{signalStrength:03d}%";
            format-ethernet = "ETH
100%";
            format-disconnected = "NET
OFF";
            tooltip = false;
          };

          "battery" = {
            states = {
              warning = 20;
              critical = 10;
            };
            format = "BAT
{capacity:03d}%";
            format-charging = "CHR
{capacity:03d}%";
            format-plugged = "PLG
{capacity:03d}%";
            tooltip-format = "{power} W
{time}";
          };

          "cpu" = {
            format = "CPU
{usage:03d}%";
            interval = 10;
            tooltip = false;
          };

          "memory" = {
            format = "RAM
{percentage:03d}%";
            interval = 10;
            tooltip = false;
          };

          "temperature" = {
            format = "TMP
{temperatureC:03d}°";
            interval = 10;
            tooltip = false;
          };

          "clock" = {
            format = "{:%d
%m
──
%H
%M}"; # https://www.reddit.com/r/unixporn/comments/1op5brb/comment/nnb1ugx/
            tooltip = false;
          };
        };
      };

      style = let
        colors = config.lib.stylix.colors;
      in ''
        * {
          font-family: "${config.stylix.fonts.monospace.name}";
          font-size: ${toString config.stylix.fonts.sizes.desktop}px;
          min-height: 0;
        }

        window#waybar {
          background: alpha(${colors.withHashtag.base00}, 0.8);
          border-radius: 4px;
        }

        #pulseaudio,
        #backlight,
        #network,
        #cpu,
        #memory,
        #temperature,
        #battery,
        #clock {
          background: alpha(${colors.withHashtag.base02}, 0.8);
          color: ${colors.withHashtag.base05};
          border-radius: 2px;
          margin: 4px;
          padding: 2px 2px;
        }

        #pulseaudio.muted {
          background: alpha(${colors.withHashtag.base02}, 0.8);
          color: ${colors.withHashtag.base05};
          border-radius: 2px;
          margin: 4px;
          padding: 2px 2px;
          border: none;
          font-weight: normal;
        }

        #workspaces {
          background: transparent;
          margin: 4px;
        }

        #pulseaudio:hover,
        #backlight:hover,
        #network:hover,
        #cpu:hover,
        #memory:hover,
        #temperature:hover,
        #battery:hover,
        #clock:hover {
          background: alpha(${colors.withHashtag.base03}, 0.8);
          color: ${colors.withHashtag.base0D};
          transition: 0.2s;
        }

        window#waybar #workspaces button {
          padding: 4px 0px;
          margin-bottom: 4px;
          color: ${colors.withHashtag.base04};
          background: alpha(${colors.withHashtag.base02}, 0.8);
          border-radius: 2px;

          border: none;
          border-bottom: 2px solid transparent;
          box-shadow: none;
        }

        window#waybar #workspaces button.focused {
          color: ${colors.withHashtag.base0D};
          background: alpha(${colors.withHashtag.base03}, 0.8);
          border: none;
          border-bottom: 2px solid transparent;

          box-shadow: none;
          text-shadow: none;
          text-decoration: none;
          font-weight: 900;
        }

        window#waybar #workspaces button:hover {
          background: alpha(${colors.withHashtag.base03}, 0.8);
          color: ${colors.withHashtag.base05};
          border-bottom: 2px solid transparent;
        }
      '';
    };
  };
}
