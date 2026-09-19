# Qt 6.11 + qt5ct QProxyStyle recursion SIGSEGVs every Qt app that
# inherits stylix's QT_QPA_PLATFORMTHEME=qt5ct (legion_gui: lll.nix
# 2026-09-15; OpenRGB GUI coredumps 2026-09-12..19, crash in
# libQt6Core.so.6.11.2 — CLI mode-sets are unaffected, they never build
# widgets). The GUI must launch with the var dropped; the package is
# wrapped wholesale because the NixOS openrgb module feeds `package` to
# BOTH the server unit and environment.systemPackages — a second,
# parallel wrapper derivation would collide with the module's own
# systemPackages entry in the buildEnv (bin/openrgb twice).
{den, ...}: {
  den.aspects.system.hardware.openrgb = {
    nixos = {pkgs, ...}: let
      openrgb-wrapped = pkgs.stdenvNoCC.mkDerivation {
        name = "openrgb-wrapped";
        meta.mainProgram = "openrgb";
        buildCommand = ''
          # Wrap the nixpkgs shim (not the inner .openrgb-wrapped) so the
          # qtHook env (QT_PLUGIN_PATH, XDG_DATA_DIRS) still applies; the
          # shim's exec inherits the --unset below.
          makeWrapper ${pkgs.unstable.openrgb}/bin/openrgb \
            $out/bin/openrgb --unset QT_QPA_PLATFORMTHEME
          # Real dir of per-entry symlinks, not a parent symlink: a
          # dangling share/* symlink breaks the buildEnv ("not a
          # directory", see lll.nix).
          mkdir -p $out/share
          for entry in ${pkgs.unstable.openrgb}/share/*; do
            ln -s "$entry" "$out/share/$(basename "$entry")"
          done
        '';
      };
    in {
      services.hardware.openrgb = {
        enable = true;
        package = openrgb-wrapped;
      };
    };
  };
}
