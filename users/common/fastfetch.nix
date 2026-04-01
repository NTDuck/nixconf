{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.unstable.fastfetch;

    settings = {
      logo = {
        source = "arch";
        padding = {
          top = 1;
          left = 2;
          right = 2;
        };
      };
      display = {
        disableLinewrap = false;
        separator = " 󰇙 ";
        constants = [
          "╭────────────────────────────────────────────────────────╮"
          "╰────────────────────────────────────────────────────────╯"
          "│                                                        │\033[57D"
        ];
      };
      modules = [
        "break"
        { type = "custom"; format = "{$1}"; }
        { type = "title"; key = "{$3}{#31}  user      "; format = "{user-name}@{host-name}"; }
        { type = "host"; key = "{$3}{#32} 󰌢 machine   "; }
        { type = "os"; key = "{$3}{#33}  os        "; }
        { type = "kernel"; key = "{$3}{#34}  kernel    "; }
        { type = "uptime"; key = "{$3}{#35}  uptime    "; }
        { type = "packages"; key = "{$3}{#36} 󰏖 packages  "; }
        { type = "shell"; key = "{$3}{#31}  shell     "; }
        { type = "display"; key = "{$3}{#32} 󰍹 display   "; }
        { type = "wm"; key = "{$3}{#34}  wm        "; }
        { type = "terminal"; key = "{$3}{#35}  terminal  "; }
        { type = "cpu"; key = "{$3}{#36}  cpu       "; }
        { type = "gpu"; key = "{$3}{#31} 󰢮 gpu       "; }
        { type = "memory"; key = "{$3}{#32}  memory    "; }
        { type = "disk"; key = "{$3}{#33} 󰋊 disk      "; }
        { type = "localip"; key = "{$3}{#34} 󰩠 local ip  "; }
        { type = "battery"; key = "{$3}{#35}  battery   "; }
        { type = "custom"; format = "{$2}"; }
        "break"
        "colors"
      ];
    };
  };

  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
