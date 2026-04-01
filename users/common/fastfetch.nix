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
        separator = "   ";
        constants = [
          # "╭──────────────┬─────────────────────────────────────────────╮"
          # "╰──────────────┴─────────────────────────────────────────────╯"
          # "│"
          "╭──────────────┬─────────────────────────────────────────────"
          "╰──────────────┴─────────────────────────────────────────────"
          "│"
        ];
      };
      modules = [
        "break"
        { type = "custom"; format = "{$1}"; }
        { type = "title"; key = "{$3} {#31} user       {$3}"; format = "{user-name}@{host-name}"; }
        { type = "host"; key = "{$3} {#32}󰌢 machine    {$3}"; }
        { type = "os"; key = "{$3} {#33} os         {$3}"; }
        { type = "kernel"; key = "{$3} {#34} kernel     {$3}"; }
        { type = "uptime"; key = "{$3} {#35} uptime     {$3}"; }
        { type = "packages"; key = "{$3} {#36}󰏖 packages   {$3}"; }
        { type = "shell"; key = "{$3} {#31} shell      {$3}"; }
        { type = "display"; key = "{$3} {#32}󰍹 display    {$3}"; }
        { type = "de"; key = "{$3} {#33}󰧨 de         {$3}"; }
        { type = "wm"; key = "{$3} {#34} wm         {$3}"; }
        { type = "wmtheme"; key = "{$3} {#35}󰉼 wm theme   {$3}"; }
        { type = "theme"; key = "{$3} {#36}󰉼 theme      {$3}"; }
        { type = "icons"; key = "{$3} {#31}󰀻 icons      {$3}"; }
        { type = "font"; key = "{$3} {#32} font       {$3}"; }
        { type = "cursor"; key = "{$3} {#33}󰇀 cursor     {$3}"; }
        { type = "terminal"; key = "{$3} {#34} terminal   {$3}"; }
        { type = "terminalfont"; key = "{$3} {#35} term font  {$3}"; }
        { type = "cpu"; key = "{$3} {#36} cpu        {$3}"; }
        { type = "gpu"; key = "{$3} {#31}󰢮 gpu        {$3}"; }
        { type = "memory"; key = "{$3} {#32} memory     {$3}"; }
        { type = "swap"; key = "{$3} {#33}󰓡 swap       {$3}"; }
        { type = "disk"; key = "{$3} {#34}󰋊 disk       {$3}"; }
        { type = "localip"; key = "{$3} {#35}󰩠 local ip   {$3}"; }
        { type = "battery"; key = "{$3} {#36} battery    {$3}"; }
        { type = "poweradapter"; key = "{$3} {#31} power      {$3}"; }
        { type = "locale"; key = "{$3} {#32} locale     {$3}"; }
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
