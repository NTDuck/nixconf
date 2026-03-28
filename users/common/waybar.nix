{ pkgs, ... }:

{
  home.packages = [ pkgs.ironbar ];

  # 1. Inject the TOML Configuration
  xdg.configFile."ironbar/config.toml".text = ''
    position = "left"

    [margin]
    top = 4
    bottom = 4
    left = 4
    right = 0

    [[start]]
    type = "workspaces"
    name = "workspaces"

    # --- AUDIO ---
    [[end]]
    type = "script"
    name = "audio"
    mode = "poll"
    interval = 500
    cmd = """
    volume=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | ${pkgs.coreutils}/bin/tr -dc '0-9.' | ${pkgs.gawk}/bin/awk '{printf "%03d", $1 * 100}')
    if ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | ${pkgs.gnugrep}/bin/grep -q MUTED; then
      printf "MUT \n%s%%" "$volume"
    else
      printf "VOL \n%s%%" "$volume"
    fi
    """

    # --- BACKLIGHT ---
    [[end]]
    type = "script"
    name = "backlight"
    mode = "poll"
    interval = 500
    cmd = """
    light=$(${pkgs.brightnessctl}/bin/brightnessctl -m | ${pkgs.gawk}/bin/awk -F, '{print substr($4, 1, length($4)-1)}')
    printf "LGT \n%03d%%" "$light"
    """

    # --- NETWORK ---
    [[end]]
    type = "script"
    name = "network"
    mode = "poll"
    interval = 2000
    cmd = """
    if ${pkgs.gnugrep}/bin/grep -q 'up' /sys/class/net/wl*/operstate 2>/dev/null; then
      printf "WIF \n100%"
    elif ${pkgs.gnugrep}/bin/grep -q 'up' /sys/class/net/e*/operstate 2>/dev/null; then
      printf "ETH \n100%"
    else
      printf "NET \nOFF "
    fi
    """

    # --- BATTERY ---
    [[end]]
    type = "battery"
    name = "battery"

    # --- CPU ---
    [[end]]
    type = "sys_info"
    name = "cpu"
    interval = 10
    format = ["CPU \n{cpu_percent:0>3}%"]

    # --- MEMORY ---
    [[end]]
    type = "sys_info"
    name = "memory"
    interval = 10
    format = ["RAM \n{memory_percent:0>3}%"]

    # --- CLOCK ---
    [[end]]
    type = "clock"
    name = "clock"
    format = "%d\n%m\n──\n%H\n%M"
  '';

  # 2. Inject the CSS Stylesheet
  xdg.configFile."ironbar/style.css".text = ''
    /*
     * IMPORTANT: If your @base... colors are NOT globally defined in GTK,
     * GTK will silently discard the background properties below.
     * You may need to replace them with hex codes (e.g., #2E3440) or
     * ensure your theming engine writes an @import "colors.css"; at the top here.
     */

    * {
      font-size: 10px;
      font-family: monospace;
    }

    .background {
      background-color: alpha(@base00, 0.85);
      border-radius: 4px;
    }

    /* Targeting outer containers strictly by ID ensures the background renders */
    #audio,
    #backlight,
    #network,
    #battery,
    #cpu,
    #memory,
    #clock {
      background-color: alpha(@base02, 0.85);
      color: @base05;
      border-radius: 2px;
      margin: 4px;
      padding: 6px 4px;
    }

    #workspaces {
      background-color: transparent;
      margin: 4px;
    }

    #audio:hover,
    #backlight:hover,
    #network:hover,
    #battery:hover,
    #cpu:hover,
    #memory:hover,
    #clock:hover {
      background-color: alpha(@base03, 0.85);
      color: @base0D;
      transition: 0.2s;
    }

    /* Workspace items inside the workspaces module */
    #workspaces .item {
      padding: 4px 0px;
      margin-bottom: 4px;
      color: @base04;
      background-color: alpha(@base02, 0.85);
      border-radius: 2px;
      border: none;
      border-bottom: 2px solid transparent;
      box-shadow: none;
    }

    #workspaces .item.focused {
      color: @base0D;
      background-color: alpha(@base03, 0.85);
      border: none;
      border-bottom: 2px solid transparent;
      font-weight: 900;
    }

    #workspaces .item:hover {
      background-color: alpha(@base03, 0.85);
      color: @base05;
      border-bottom: 2px solid transparent;
    }
  '';
}
