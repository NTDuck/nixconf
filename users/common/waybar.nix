{ pkgs, ... }:

{
  # 1. Install the Ironbar package
  home.packages = [ pkgs.unstable.ironbar ];

  # 2. Inject the TOML Configuration
  xdg.configFile."ironbar/config.toml".text = ''
    position = "left"

    [margin]
    top = 4
    bottom = 4
    left = 4
    right = 0

    [[start]]
    type = "workspaces"

    # --- AUDIO (Scripted to preserve text grid) ---
    [[end]]
    type = "script"
    name = "audio"
    mode = "poll"
    interval = 500
    cmd = """
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tr -dc '0-9.' | awk '{printf "%03d", $1 * 100}')
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
      printf "MUT \n%s%%" "$volume"
    else
      printf "VOL \n%s%%" "$volume"
    fi
    """

    # --- BACKLIGHT (Scripted to preserve text grid) ---
    [[end]]
    type = "script"
    name = "backlight"
    mode = "poll"
    interval = 500
    cmd = """
    light=$(brightnessctl -m | awk -F, '{print substr($4, 1, length($4)-1)}')
    printf "LGT \n%03d%%" "$light"
    """

    # --- NETWORK (Scripted for fallback logic) ---
    [[end]]
    type = "script"
    name = "network"
    mode = "poll"
    interval = 2000
    cmd = """
    if grep -q 'up' /sys/class/net/wl*/operstate 2>/dev/null; then
      printf "WIF \n100%"
    elif grep -q 'up' /sys/class/net/e*/operstate 2>/dev/null; then
      printf "ETH \n100%"
    else
      printf "NET \nOFF "
    fi
    """

    # --- BATTERY ---
    [[end]]
    type = "battery"

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
    format = "%d\n%m\n──\n%H\n%M"
  '';

  # 3. Inject the CSS Stylesheet
  xdg.configFile."ironbar/style.css".text = ''
    * {
      font-size: 10px;
      font-family: monospace;
      min-height: 0;
    }

    .background {
      background: alpha(@base00, 0.85);
      border-radius: 4px;
    }

    /* Target the custom script modules by their assigned names, and native modules by class */
    #audio,
    #backlight,
    #network,
    .battery,
    #cpu,
    #memory,
    .clock {
      background: alpha(@base02, 0.85);
      color: @base05;
      border-radius: 2px;
      margin: 4px;
      padding: 6px 4px;
    }

    .workspaces {
      background: transparent;
      margin: 4px;
    }

    #audio:hover,
    #backlight:hover,
    #network:hover,
    .battery:hover,
    #cpu:hover,
    #memory:hover,
    .clock:hover {
      background: alpha(@base03, 0.85);
      color: @base0D;
      transition: 0.2s;
    }

    .workspaces .item {
      padding: 4px 0px;
      margin-bottom: 4px;
      color: @base04;
      background: alpha(@base02, 0.85);
      border-radius: 2px;
      border: none;
      border-bottom: 2px solid transparent;
      box-shadow: none;
    }

    .workspaces .item.focused {
      color: @base0D;
      background: alpha(@base03, 0.85);
      border: none;
      border-bottom: 2px solid transparent;
      box-shadow: none;
      text-shadow: none;
      text-decoration: none;
      font-weight: 900;
    }

    .workspaces .item:hover {
      background: alpha(@base03, 0.85);
      color: @base05;
      border-bottom: 2px solid transparent;
    }
  '';
}
