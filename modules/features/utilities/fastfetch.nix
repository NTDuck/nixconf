{den, ...}: {
  den.aspects.utilities.fastfetch = {
    # TODO Better view
    home-manager = {pkgs, ...}: {
      programs.fastfetch = {
        enable = true;
        package = pkgs.unstable.fastfetch;

        settings = {
          logo = {
            source = "arch2";
            padding = {
              top = 1;
              left = 2;
              right = 2;
            };
          };
          display = {
            disableLinewrap = false;
            separator = "   ";
          };
          modules = [
            "break"
            {
              type = "title";
              key = "  {#31} user        ";
              format = "{user-name}@{host-name}";
            }
            {
              type = "host";
              key = "  {#32}󰌢 machine     ";
            }
            {
              type = "os";
              key = "  {#33} os          ";
            }
            {
              type = "kernel";
              key = "  {#34} kernel      ";
            }
            {
              type = "uptime";
              key = "  {#35} uptime      ";
            }
            {
              type = "packages";
              key = "  {#36}󰏖 packages    ";
            }
            {
              type = "shell";
              key = "  {#31} shell       ";
            }
            {
              type = "display";
              key = "  {#32}󰍹 display     ";
            }
            {
              type = "de";
              key = "  {#33}󰧨 de          ";
            }
            {
              type = "wm";
              key = "  {#34} wm          ";
            }
            {
              type = "wmtheme";
              key = "  {#35}󰉼 wm theme    ";
            }
            {
              type = "theme";
              key = "  {#36}󰉼 theme       ";
            }
            {
              type = "icons";
              key = "  {#31}󰀻 icons       ";
            }
            {
              type = "font";
              key = "  {#32} font        ";
            }
            {
              type = "cursor";
              key = "  {#33}󰇀 cursor      ";
            }
            {
              type = "terminal";
              key = "  {#34} terminal    ";
            }
            {
              type = "terminalfont";
              key = "  {#35} term font   ";
            }
            {
              type = "cpu";
              key = "  {#36} cpu         ";
            }
            {
              type = "gpu";
              key = "  {#31}󰢮 gpu         ";
            }
            {
              type = "memory";
              key = "  {#32} memory      ";
            }
            {
              type = "swap";
              key = "  {#33}󰓡 swap        ";
            }
            {
              type = "disk";
              key = "  {#34}󰋊 disk        ";
            }
            {
              type = "localip";
              key = "  {#35}󰩠 local ip    ";
            }
            {
              type = "battery";
              key = "  {#36} battery     ";
            }
            {
              type = "poweradapter";
              key = "  {#31} power       ";
            }
            {
              type = "locale";
              key = "  {#32} locale      ";
            }
            "break"
            {
              type = "colors";
              paddingLeft = 19;
            }
          ];
        };
      };

      home.shellAliases = {
        ff = "${pkgs.unstable.fastfetch}/bin/fastfetch";
      };
    };
  };
}
