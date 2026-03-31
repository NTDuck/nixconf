{ pkgs, ... }:

{
  programs.fastfetch = {
    enable = true;
    package = pkgs.unstable.fastfetch;

    settings = {
      logo = {
        source = "arch";
        padding = {
          top = 2;
        };
      };

      display = {
        disableLinewrap = false;
        separator = "";
        key = {
          width = 16;
        };
        constants = [
          # CONSTANT {$1} - COLOR BACKGROUND FOR KEY
          "\\u001b[48;2;43;43;69m"
          # CONSTANT {$2} - COLOR BACKGROUND FOR OUTPUT
          "\\u001b[48;2;56;59;78m"
          # CONSTANT {$3} - VERTICAL BARS AT START AND 75th CHARACTERS FORWARD AND BACKWARD
          "\\u001b[90m│                                                            │\\u001b[60D\\u001b[39m"
        ];
      };

      modules = [
        # --- Top UI Bar ---
        {
          type = "custom";
          key = "{#90}{$1}╭─────────────╮";
          format = "{#90}{$2}╭────────────────────────────────────────────────────────────╮";
        }

        # --- User & Session Info ---
        {
          type = "title";
          key = "{#90}{$1}│ {#92}User        {#90}│";
          format = "{$2}{$3}{user-name} {#2}[{home-dir}]";
        }
        {
          type = "users";
          key = "{#90}{$1}│ {#92}Users       {#90}│";
          myselfOnly = false;
          format = "{$2}{$3}{1}@{host-name}  {#2}[IP:{client-ip}]  {#2}[Login time: {login-time}]";
        }
        {
          type = "datetime";
          key = "{#90}{$1}│ {#92}Datetime    {#90}│";
          format = "{$2}{$3}{year}-{month-pretty}-{day-in-month}  {hour-pretty}:{minute-pretty}:{second-pretty}  {#2}{weekday}  {#2}[W{week}] {#2}[UTC{offset-from-utc}]";
        }

        # --- Host & OS Info ---
        {
          type = "title";
          key = "{#90}{$1}│ {#93}Host:       {#90}│";
          format = "{$2}{$3}{#1}{#36}{host-name}";
        }
        {
          type = "host";
          key = "{#90}{$1}│ {#93}Machine     {#90}│";
          format = "{$2}{$3}{name} {#2}{version}";
        }
        {
          type = "os";
          key = "{#90}{$1}│ {#93}OS          {#90}│";
          format = "{$2}{$3}{pretty-name} {codename} {#2}[v{version}] {#2}[{arch}]";
        }
        {
          type = "kernel";
          key = "{#90}{$1}│ {#93}Kernel      {#90}│";
          format = "{$2}{$3}{sysname} {#2}[v{release}]";
        }
        {
          type = "uptime";
          key = "{#90}{$1}│ {#93}Uptime      {#90}│";
          format = "{$2}{$3}{days} Days + {hours}:{minutes}:{seconds}";
        }

        # --- Hardware Info ---
        {
          type = "cpu";
          key = "{#90}{$1}│ {#91}CPU         {#90}│";
          showPeCoreCount = true;
          temp = true;
          format = "{$2}{$3}{name} {#2}[C:{core-types}] {#2}[{freq-max}]";
        }
        {
          type = "gpu";
          key = "{#90}{$1}│ {#91}GPU         {#90}│";
          detectionMethod = "auto";
          hideType = "none";
          temp = true;
          format = "{$2}{$3}{name} {#2}[C:{core-count}] {#2}[{type}]";
        }
        {
          type = "memory";
          key = "{#90}{$1}│ {#91}Memory      {#90}│";
          format = "{$2}{$3}{used} / {total} ({percentage}{$2})";
        }
        {
          type = "disk";
          key = "{#90}{$1}│ {#91}Disk        {#90}│";
          format = "{$2}{$3}{size-used} / {size-total} ({size-percentage}{$2})";
        }
        {
          type = "poweradapter";
          key = "{#90}{$1}│ {#91}Power       {#90}│";
          format = "{$2}{$3}{name}";
        }

        # --- Environment & Network ---
        {
          type = "terminal";
          key = "{#90}{$1}│ {#95}Terminal    {#90}│";
          format = "{$2}{$3}{pretty-name} {#2}[{version}]";
        }
        {
          type = "terminalfont";
          key = "{#90}{$1}│ {#95}Font        {#90}│";
          format = "{$2}{$3}{name}  {#2}[{size}]";
        }
        {
          type = "shell";
          key = "{#90}{$1}│ {#95}Shell       {#90}│";
          format = "{$2}{$3}{exe-name}  {#2}[v{version}] {#2}[{exe-path}] {#2}[PID:{pid}]";
        }
        {
          type = "localip";
          key = "{#90}{$1}│ {#94}Local IPv4  {#90}│";
          showPrefixLen = true;
          showIpv4 = true;
          showIpv6 = false;
          format = "{$2}{$3}{ifname}: {ipv4}  {#2}[MTU:{mtu}]";
        }
        {
          type = "localip";
          key = "{#90}{$1}│ {#94}Local IPv6  {#90}│";
          showPrefixLen = true;
          showIpv4 = false;
          showIpv6 = true;
          format = "{$2}{$3}{ifname}: {ipv6}  {#2}[MTU:{mtu}]";
        }
        {
          type = "publicip";
          key = "{#90}{$1}│ {#94}Public IPv4 {#90}│";
          format = "{$2}{$3}{ip}  {#2}[{location}]";
        }

        # --- Bottom UI Bar ---
        {
          type = "custom";
          key = "{#90}{$1}╰─────────────╯";
          format = "{#90}{$2}╰────────────────────────────────────────────────────────────╯";
        }
      ];
    };
  };

  programs.zsh.shellAliases = {
    ff = "fastfetch";
  };
}
