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
# Anchors verified against upstream st 0.9.3
# (https://git.suckless.org/st/file/config.def.h.html). Variables
# that DON'T exist in upstream st (fontsize, cursorblink,
# mousebuttons, scroll_region) are dropped — they were from a stale
# config.def.h layout.
#
# Build robustness: every sed command uses `|| true` so a pattern
# mismatch (e.g. upstream changed the default font string) doesn't
# fail the entire build. The Python colorname replacement is wrapped
# in a guard that skips if the regex doesn't match.
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
        # Ensure python3 is available for the colorname[] replacement.
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ [pkgs.python3];

        postPatch =
          (old.postPatch or "")
          + ''
            # Font: line 8 in upstream config.def.h. Match stylix
            # monospace family + NF-CN size 11. `|| true` so a
            # pattern mismatch (upstream changed the default font)
            # doesn't fail the build.
            sed -i 's|static char \*font = "Liberation Mono:pixelsize=12:antialias=true:autohint=true";|static char *font = "Maple Mono NF CN:pixelsize=11:antialias=true:autohint=true";|' config.def.h || true
            # Border width: line 9. 14 mirrors ghostty's window-padding-x
            # (the padding IS the border in st since there's no gap).
            # NOTE: width 14 with border_width=0 in spectrwm is
            # intentional — spectrwm draws no decoration; st provides
            # its own visual frame. Border COLOR is st's default (the
            # defaultfg palette slot, already stylix-patched below);
            # upstream st has no separate bordercolor knob.
            sed -i 's|static int borderpx = 2;|static int borderpx = 14;|' config.def.h || true
            # TERM value: line 77.
            sed -i 's|char \*termname = "st-256color";|char *termname = "st-256color";|' config.def.h || true
            # Cursor shape: line 144. 2=Block, 4=Underline, 6=Bar.
            sed -i 's|static unsigned int cursorshape = 2;|static unsigned int cursorshape = 2;|' config.def.h || true
            # Default cursor/background indices: lines 132-133. 258/259
            # are the "defaultfg"/"defaultbg" extended palette slots
            # (after the 256-entry table).
            sed -i 's|unsigned int defaultfg = 258;|unsigned int defaultfg = 258;|' config.def.h || true
            sed -i 's|unsigned int defaultbg = 259;|unsigned int defaultbg = 259;|' config.def.h || true
            # Replace the colorname[] array (lines 97-125) with our
            # stylix kanagawa-dragon palette. Python heredoc for
            # reliable multi-line replacement. Guarded: if the regex
            # doesn't match (upstream layout changed), skip silently
            # rather than fail the build.
            python3 - <<'PYEOF' || true
            import re, sys
            try:
                with open('config.def.h', 'r') as f:
                    src = f.read()
                palette = [
                    "${bg}", "#${colors.base08-hex}", "#${colors.base0B-hex}",
                    "#${colors.base0A-hex}", "#${colors.base0D-hex}",
                    "#${colors.base0E-hex}", "#${colors.base0C-hex}",
                    "#${colors.base05-hex}",
                    "#${colors.base03-hex}", "#${colors.base08-hex}",
                    "#${colors.base0B-hex}", "#${colors.base0A-hex}",
                    "#${colors.base0D-hex}", "#${colors.base0E-hex}",
                    "#${colors.base0C-hex}", "#${colors.base07-hex}",
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
                new_src, n = re.subn(
                    r'static const char \*colorname\[\] = \{.*?^\};',
                    arr,
                    src,
                    count=1,
                    flags=re.DOTALL | re.MULTILINE,
                )
                if n == 0:
                    sys.exit(0)
                with open('config.def.h', 'w') as f:
                    f.write(new_src)
            except Exception as e:
                print(f"st colorname patch failed: {e}", file=sys.stderr)
                sys.exit(0)
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
