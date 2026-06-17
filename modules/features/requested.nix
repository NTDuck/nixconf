{den, ...}: {
  # Add features for all hosts
  den.aspects.p7zip = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.p7zip];
    };
  };

  den.aspects.nodejs = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.nodejs];
    };
  };

  # Host-specific extra features
  den.aspects.cmake = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.cmake];};
  };

  den.aspects.deno = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.deno];};
  };

  den.aspects.docker = {
    nixos = {pkgs, ...}: {
      virtualisation.docker.enable = true;
      environment.systemPackages = [pkgs.docker-compose];
    };
  };

  den.aspects.ffmpeg = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.ffmpeg];};
  };

  den.aspects.gallery-dl = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.gallery-dl];};
  };

  den.aspects.gcc = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.gcc];};
  };

  den.aspects.git-xet = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.git-xet];};
  };

  den.aspects.go = {
    homeManager = {pkgs, ...}: {programs.go.enable = true;};
  };

  den.aspects.gradle = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.gradle];};
  };

  den.aspects.itch = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.itch];};
  };

  den.aspects.llama = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.llama-cpp];};
  };

  den.aspects.llvm = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.llvm];};
  };

  den.aspects.miktex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.texlive.combined.scheme-full];};
  };

  den.aspects.mingw = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.mingw-w64];};
  };

  den.aspects.notion = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.notion-app-enhanced];};
  };

  den.aspects.obs-studio = {
    homeManager = {pkgs, ...}: {
      programs.obs-studio.enable = true;
    };
  };

  den.aspects.opencode = {
    homeManager = {pkgs, ...}: {programs.vscode.enable = true;};
  };

  den.aspects.openjdk = {
    homeManager = {pkgs, ...}: {programs.java.enable = true;};
  };

  den.aspects.pandoc = {
    homeManager = {pkgs, ...}: {programs.pandoc.enable = true;};
  };

  den.aspects.poetry = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.poetry];};
  };

  den.aspects.protonvpn = {
    nixos = {pkgs, ...}: {environment.systemPackages = [pkgs.protonvpn-gui];};
  };

  den.aspects.rufus = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.impression];}; # rufus alt
  };

  den.aspects.telegram = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.telegram-desktop];};
  };

  den.aspects.virtualbox = {
    nixos = {pkgs, ...}: {virtualisation.virtualbox.host.enable = true;};
  };

  den.aspects.vivaldi = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.vivaldi];};
  };

  den.aspects.vortex = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.bottles];}; # vortex alt
  };

  den.aspects.webtorrent = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.webtorrent_desktop];};
  };

  den.aspects.xmake = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.xmake];};
  };

  den.aspects.yt-dlp = {
    homeManager = {pkgs, ...}: {home.packages = [pkgs.yt-dlp];};
  };

  den.aspects.Hyprland = {
    nixos = {pkgs, ...}: {programs.hyprland.enable = true;};
  };

  den.aspects.Noctalia-shell = {
    homeManager = {pkgs, ...}: {programs.nushell.enable = true;}; # noctalia alt
  };

  den.aspects.wezterm = {
    homeManager = {pkgs, ...}: {programs.wezterm.enable = true;};
  };
}
