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
#
# Anchors verified against upstream
# https://git.suckless.org/st/file/config.def.h.html (lines noted in
# comments). Variables that DON'T exist in upstream st (fontsize,
# cursorblink, mousebuttons, scroll_region) are dropped — they were
# from a stale config.def.h layout.
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
      patchedSt = pkgs.st.overrideAttrs (old: {
        # Use postPatch with sed for targeted replacements against
        # stable string anchors. Quilt patches require exact line
        # offsets matching upstream's config.def.h layout, which
        # drifts between st versions.
        postPatch =
          (old.postPatch or "")
          + ''
            # Font: line 8 in upstream config.def.h. Match stylix
            # monospace family + NF-CN size 11.
            sed -i 's|static char \*font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";|static char *font = "Maple Mono NF CN:pixelsize=11:antialias=true:autohint=true";|' config.def.h
            # Border width: line 9.
            sed -i 's|static int borderpx = 2;|static int borderpx = 2;|' config.def.h
            # TERM value: line 77.
            sed -i 's|char \*termname = "st-256color";|char *termname = "st-256color";|' config.def.h
            # Cursor shape: line 144. 2=Block, 4=Underline, 6=Bar.
            sed -i 's|static unsigned int cursorshape = 2;|static unsigned int cursorshape = 2;|' config.def.h
            # Default cursor/background indices: lines 132-133. 258/259
            # are the "defaultfg"/"defaultbg" extended palette slots
            # (after the 256-entry table).
            sed -i 's|unsigned int defaultfg = 258;|unsigned int defaultfg = 258;|' config.def.h
            sed -i 's|unsigned int defaultbg = 259;|unsigned int defaultbg = 259;|' config.def.h
            # Replace the colorname[] array (lines 97-125) with our
            # stylix kanagawa-dragon palette. Python heredoc for
            # reliable multi-line replacement.
            python3 - <<'PYEOF'
            import re
            with open('config.def.h', 'r') as f:
                src = f.read()
            palette = [
                "${bg}", "${colors.base08-hex}", "${colors.base0B-hex}",
                "${colors.base0A-hex}", "${colors.base0D-hex}",
                "${colors.base0E-hex}", "${colors.base0C-hex}",
                "${colors.base05-hex}",
                "${colors.base03-hex}", "${colors.base08-hex}",
                "${colors.base0B-hex}", "${colors.base0A-hex}",
                "${colors.base0D-hex}", "${colors.base0E-hex}",
                "${colors.base0C-hex}", "${colors.base07-hex}",
            ]
            arr_lines = ["static const char *colorname[] = {"]
            arr_lines.append("\t/* 8 normal colors */")
            for i, c in enumerate(palette[:8]):
                arr_lines.append(f'\t"{c}",')
            arr_lines.append("")
            arr_lines.append("\t/* 8 bright colors */")
            for i, c in enumerate(palette[8:16]):
                arr_lines.append(f'\t"{c}",')
            arr_lines.append("")
            arr_lines.append("\t[255] = 0,")
            arr_lines.append("")
            arr_lines.append("\t/* more colors can be added after 255 to use with DefaultXX */")
            arr_lines.append(f'\t"${cursor}",')
            arr_lines.append(f'\t"${selBg}",')
            arr_lines.append(f'\t"${cursor}", /* default foreground colour */')
            arr_lines.append(f'\t"${bg}", /* default background colour */')
            arr_lines.append("};")
            arr = "\n".join(arr_lines)
            src = re.sub(
                r'static const char \*colorname\[\] = \{.*?^\};',
                arr,
                src,
                count=1,
                flags=re.DOTALL | re.MULTILINE,
            )
            with open('config.def.h', 'w') as f:
                f.write(src)
            PYEOF
          '';
      });
    in {
      home.packages = [patchedSt];

      # Export the patched binary path. The spectrwm aspect reads
      # TERMINAL from sessionVariables to keep both references in
      # sync — using pkgs.st here would resolve to the unpatched
      # upstream binary.
      home.sessionVariables = {
        TERMINAL = "${patchedSt}/bin/st";
      };
    };
  };
}
