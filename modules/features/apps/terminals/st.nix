# st (suckless simple terminal) for the DELL X11 session.
#
# st has no HM module (verified against
# https://github.com/nix-community/home-manager/tree/release-26.05/modules/programs
# — no st.nix). The package is `pkgs.st`; we override `config.def.h`
# via `postPatch` using `sed` for targeted replacements. st's Makefile
# generates `config.h` from `config.def.h` via `$(CPP)` at build time,
# so we patch `config.def.h` (not `config.h`).
#
# Colors are read from stylix (kanagawa-dragon palette) so st matches
# the rest of the desktop. Settings mirror ghostty where the option
# maps cleanly (cursor style, padding).
{den, ...}: {
  den.aspects.apps.terminals.st = {
    homeManager = {
      config,
      pkgs,
      ...
    }: let
      colors = config.lib.stylix.colors;
      bg = "#${colors.base00-hex}";
      fg = "#${colors.base05-hex}";
      cursor = "#${colors.base05-hex}";
      selBg = "#${colors.base02-hex}";
      selFg = "#${colors.base05-hex}";
    in {
      home.packages = let
        st = pkgs.st.overrideAttrs (old: {
          # Use postPatch with sed for targeted replacements. Quilt
          # patches require exact line offsets matching upstream's
          # config.def.h layout, which drifts between st versions.
          # sed on stable string anchors is robust against line shifts.
          postPatch =
            (old.postPatch or "")
            + ''
              # Terminal name (used by $TERM for apps that check it).
              sed -i 's|static const char \*termname = "st-256color";|static const char *termname = "st-256color";|' config.def.h
              # Font size.
              sed -i 's|static const int fontsize = [0-9]*;|static const int fontsize = 11;|' config.def.h
              # Border width.
              sed -i 's|static const int borderpx = [0-9]*;|static const int borderpx = 2;|' config.def.h
              # External padding (x, y).
              sed -i 's|static const int chscale = [0-9]*;|static const int chscale = 14;|' config.def.h
              # Cursor style: 1=block, 2=underline, 3=bar.
              sed -i 's|static unsigned int cursorshape = [0-9]*;|static unsigned int cursorshape = 1;|' config.def.h
              # Cursor blink: 0=off.
              sed -i 's|static const int cursorblink = [0-9]*;|static const int cursorblink = 0;|' config.def.h
              # Mouse support.
              sed -i 's|static uint mousebuttons = [0-9]*;|static uint mousebuttons = 3;|' config.def.h
              # Scroll region (mouse wheel scrolls in the alternate screen).
              sed -i 's|static int scroll_region = [0-9]*;|static int scroll_region = 1;|' config.def.h
              # Colors: replace the defaultfg/defaultbg indices with 256/257
              # (the extended "default" colors) so the colorname[] array
              # below can be overridden with our stylix palette.
              sed -i 's|unsigned int defaultfg = [0-9]*;|unsigned int defaultfg = 256;|' config.def.h
              sed -i 's|unsigned int defaultbg = [0-9]*;|unsigned int defaultbg = 257;|' config.def.h
              # Replace the colorname[] array with our stylix palette.
              # The array has 16 entries (indices 0-15) plus 2 extended
              # (256=defaultfg, 257=defaultbg). We use a Python heredoc
              # to write the array reliably.
              python3 - <<'PYEOF'
              import re
              with open('config.def.h', 'r') as f:
                  src = f.read()
              palette = [
                  "${bg}", "${colors.base08-hex}", "${colors.base0B-hex}",
                  "${colors.base0A-hex}", "${colors.base0D-hex}",
                  "${colors.base0E-hex}", "${colors.base0C-hex}",
                  "${colors.base05-hex}", "${colors.base03-hex}",
                  "${colors.base08-hex}", "${colors.base0B-hex}",
                  "${colors.base0A-hex}", "${colors.base0D-hex}",
                  "${colors.base0E-hex}", "${colors.base0C-hex}",
                  "${colors.base07-hex}", "${cursor}", "${selBg}",
              ]
              arr = "static const char *colorname[] = {\n"
              for i, c in enumerate(palette):
                  arr += f'\t"{c}", /* {i} */\n'
              arr += "};\n"
              src = re.sub(
                  r'static const char \*colorname\[\] = \{.*?\};',
                  arr.rstrip('\n'),
                  src,
                  count=1,
                  flags=re.DOTALL,
              )
              with open('config.def.h', 'w') as f:
                  f.write(src)
              PYEOF
            '';
        });
      in [
        st
      ];

      home.sessionVariables = {
        TERMINAL = "${pkgs.st}/bin/st";
      };
    };
  };
}
