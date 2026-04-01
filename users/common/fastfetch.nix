{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.unstable.fastfetch;

    settings = {
      logo = {
        type = "none";
        padding = {
          top = 1;
          left = 2;
          right = 2;
        };
      };
      display = {
        disableLinewrap = false;
        separator = "  ";
        constants = [
          "╭─────────────┬────────────────────────────────────────────╮"
          "╰─────────────┴────────────────────────────────────────────╯"
          "│"
        ];
      };
      modules = [
        "break"
        { type = "custom"; format = "{$1}"; }
        { type = "title"; key = "{$3} {#31} user      {$3}"; format = "{user-name}@{host-name}"; }
        { type = "os"; key = "{$3} {#32} os        {$3}"; }
        { type = "kernel"; key = "{$3} {#33} kernel    {$3}"; }
        { type = "uptime"; key = "{$3} {#34} uptime    {$3}"; }
        { type = "packages"; key = "{$3} {#35}󰏖 packages  {$3}"; }
        { type = "shell"; key = "{$3} {#36} shell     {$3}"; }
        { type = "wm"; key = "{$3} {#31} wm        {$3}"; }
        { type = "terminal"; key = "{$3} {#32} terminal  {$3}"; }
        { type = "cpu"; key = "{$3} {#33} cpu       {$3}"; }
        { type = "gpu"; key = "{$3} {#34}󰢮 gpu       {$3}"; }
        { type = "memory"; key = "{$3} {#35} memory    {$3}"; }
        { type = "custom"; format = "{$2}"; }
        "break"
      ];
    };
  };

  programs.zsh.shellAliases = {
    nf = "fastfetch";
  };
}
