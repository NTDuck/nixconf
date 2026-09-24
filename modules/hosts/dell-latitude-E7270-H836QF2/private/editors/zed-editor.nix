# Zed sizing for DELL (2026-09-24): the shared zed aspect + stylix zed
# target set buffer/ui font sizes from stylix `sizes.terminal/
# applications * 4/3` (= 14.6667 pt). That is tuned for legion's 189-dpi
# 1.5x-scaled panel; on the 12.5" 1366x768 panel (~125 physical dpi at
# 96 dpi X) the same point size renders visibly larger — "zeditor too
# big". Cap the sizes here (dell-only; legion keeps the shared value).
{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {lib, ...}: {
      programs.zed-editor.userSettings = {
        # 11 pt ≈ the urxvt/bar glyph size on this panel.
        buffer_font_size = lib.mkForce 11.0;
        ui_font_size = lib.mkForce 10.0;
      };
    };
  };
}
