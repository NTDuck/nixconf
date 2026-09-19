# moonlight-qt client; pairs with the sunshine host on the Legion over LAN
{...}: {
  den.aspects.remote-desktop.moonlight = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        # Wrapper forces --no-yuv444 (2026-09-18): with the "Enable YUV 4:4:4
        # (Experimental)" pref on, sunshine streams H.264 High 4:4:4
        # Predictive, which the E7270's HD 520 (Gen9 i965) cannot
        # hardware-decode -> "H.264 decode error". Moonlight's own VDS_AUTO
        # drop-fallback is not reliable on this stack, and no sunshine.conf
        # key can refuse 4:4:4 (verified in Sunshine src/config.cpp: zero
        # chroma keys). CLI overrides the saved pref on every launch, so the
        # toggle cannot regress it. 4:2:0 High decodes fine on the fixed-
        # function block.
        (pkgs.writeShellScriptBin "moonlight-qt" ''
          # Qt 6.11 + qt5ct QProxyStyle recursion SIGSEGVs Qt apps that
          # inherit stylix's QT_QPA_PLATFORMTHEME=qt5ct (same class as the
          # legion openrgb/legion_gui crashes, fixed 2026-09-19); shell-side
          # unset — writeShellScriptBin in home.packages, no package slot to
          # collide with.
          unset QT_QPA_PLATFORMTHEME
          exec ${pkgs.moonlight-qt}/bin/moonlight-qt --no-yuv444 "$@"
        '')
      ];
    };
  };
}
