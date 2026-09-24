# rxvt-unicode (urxvt) terminal for the DELL X11 session (2026-09-24),
# replacing the patched st (deleted in the same commit — history has it).
#
# HM ships a real urxvt module (programs.urxvt — verified against
# home-manager release-26.05 modules/programs/urxvt.nix: enable, package,
# fonts, keybindings, scroll.*, extraConfig → URxvt.* xresources).
# Stylix has NO urxvt target (grep over stylix a01dcef2 returned nothing),
# so colors are set manually via extraConfig using the stylix palette,
# mirroring the old st aspect's base16 mapping (bg=base00,
# fg/cursor=base05, normals 00/08/0B/0A/0D/0E/0C/05, brights
# 03/08/0B/0A/0D/0E/0C/07).
#
# TERMINAL: exported via home.sessionVariables so the spectrwm aspect's
# `programs.term` (config.home.sessionVariables.TERMINAL or fallback)
# picks up the urxvt binary — same contract the old st aspect used.
#
# NixOS terminfo: rxvt-unicode ships rxvt-unicode(-256color) terminfo in
# its share/terminfo, but HM's home.packages do NOT feed NixOS's system
# terminfo aggregation (verified on dell 2026-09-24: `infocmp
# rxvt-unicode-256color` fails system-wide). The nixos block below adds
# the package to environment.systemPackages so SSH/tmux/less get a
# working TERM=rxvt-unicode-256color.
{den, ...}: {
  den.aspects.apps.terminals.urxvt = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      programs.urxvt = {
        enable = true;
        package = pkgs.rxvt-unicode;
        # st used "Maple Mono NF CN:pixelsize=11"; keep the same metric.
        fonts = ["xft:Maple Mono NF CN:pixelsize=11"];
        # st has no scrollbar; urxvt's default plain bar is off to match.
        scroll.bar.enable = false;
        # X clipboard integration (urxvt manages PRIMARY only by default).
        keybindings = {
          "Shift-Control-C" = "eval:selection_to_clipboard";
          "Shift-Control-V" = "eval:paste_clipboard";
        };
        # No stylix target (see header) — palette via xresources.
        # '#' as the first char of a VALUE is fine in X resource files;
        # XParseColor accepts the #RRGGBB form.
        extraConfig = let
          c = config.lib.stylix.colors;
        in {
          # st's borderpx=14 — in a borderless tiler the padding IS the
          # frame, and urxvt's internalBorder is its padding.
          internalBorder = 14;
          background = "#${c.base00-hex}";
          foreground = "#${c.base05-hex}";
          cursorColor = "#${c.base05-hex}";
          color0 = "#${c.base00-hex}";
          color1 = "#${c.base08-hex}";
          color2 = "#${c.base0B-hex}";
          color3 = "#${c.base0A-hex}";
          color4 = "#${c.base0D-hex}";
          color5 = "#${c.base0E-hex}";
          color6 = "#${c.base0C-hex}";
          color7 = "#${c.base05-hex}";
          color8 = "#${c.base03-hex}";
          color9 = "#${c.base08-hex}";
          color10 = "#${c.base0B-hex}";
          color11 = "#${c.base0A-hex}";
          color12 = "#${c.base0D-hex}";
          color13 = "#${c.base0E-hex}";
          color14 = "#${c.base0C-hex}";
          color15 = "#${c.base07-hex}";
        };
      };

      home.sessionVariables = {
        TERMINAL = "${pkgs.rxvt-unicode}/bin/urxvt";
      };
    };

    nixos = {pkgs, ...}: {
      # Terminfo aggregation is system-packages-only (see header).
      environment.systemPackages = [pkgs.rxvt-unicode];
    };
  };
}
