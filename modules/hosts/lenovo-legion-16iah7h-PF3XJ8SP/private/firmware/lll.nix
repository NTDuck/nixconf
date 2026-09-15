{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      ...
    }: let
      # legion_gui segfaults on Qt 6.11 when QT_QPA_PLATFORMTHEME=qt5ct is
      # set (stylix HM qt target exports it via environment.d): the qt6ct
      # platform theme wraps style creation in QProxyStyle and re-enters
      # QStyleFactory forever with style=kvantum -> standardPalette
      # recursion -> SIGSEGV (coredump 2026-09-15). Without the platform
      # theme env, QStyleFactory loads the kvantum plugin directly and works
      # (bisected with offscreen runs; QT_STYLE_OVERRIDE alone is safe).
      # The kvantum plugin below is still required for that direct load.
      legion = pkgs.stdenvNoCC.mkDerivation {
        name = "lenovo-legion-wrapped";
        nativeBuildInputs = [pkgs.makeBinaryWrapper];
        # Desktop entry's Exec (`legion_gui --use_legion_cli_to_write`) keeps
        # resolving; the wrapper only drops the env var that crashes Qt 6.11.
        buildCommand = ''
          makeWrapper ${pkgs.unstable.lenovo-legion}/bin/.legion_gui-wrapped \
            $out/bin/legion_gui --unset QT_QPA_PLATFORMTHEME
          # Share everything the app ships (applications/, pixmaps/,
          # legion_linux/, polkit-1/) instead of guessing per-dir: the icon
          # lives in share/pixmaps and there is NO share/icons upstream —
          # a dangling share/icons symlink broke buildEnv (system-path
          # "not a directory", 2026-09-15).
          ln -s ${pkgs.unstable.lenovo-legion}/share $out/share
        '';
      };
    in {
      environment.systemPackages = [
        legion
        # qt6ct.conf sets style=kvantum; without the style plugin Qt cannot
        # load it directly and legion_gui segfaults (QProxyStyle recursion).
        pkgs.qt6Packages.qtstyleplugin-kvantum
      ];

      boot.extraModulePackages = [config.boot.kernelPackages.lenovo-legion-module];
      boot.kernelModules = ["legion_laptop"];

      # legion-laptop binds Lenovo's WMI gamezone/capdata/hotkey GUIDs itself,
      # so the in-kernel equivalents must stay unloaded or they claim the
      # device first.
      boot.extraModprobeConfig = ''
        blacklist ideapad_acpi
        blacklist ideapad_laptop
        blacklist lenovo_wmi_events
        blacklist lenovo_wmi_hotkey_utilities
        blacklist lenovo_wmi_other
        blacklist lenovo_wmi_capdata01
        blacklist lenovo_wmi_gamezone
        blacklist lenovo_wmi_helpers
        blacklist lenovo_wmi_capdata
      '';

      # [[1]] In [[Fan Curve]], apply [[performance-ac]] preset + [Minifancurve if too cold]
      # [[2]] In [[Other Options]], apply:
      # | Configuration                        | Default   | Custom   |
      # | ------------------------------------ | --------- | -------: |
      # | CPU Long Term Power Limit [W] (PL1)  |        60 |      115 |
      # | CPU Short Term Power Limit [W] (PL2) | 45/80/135 |      135 |
      # | CPU Peak Power Limit [W]             |         0 |        0 |
      # | CPU Cross Loading Power Limit [W]    |         0 |        0 |
      # | CPU APU SPPT Power Limit [W]         |         0 |        0 |
      # | GPU cTGP Power Limit [W]             |         0 |      140 |
      # | GPU PPAB Power Limit [W]             |        15 |       25 |
      # | GPU Temperature Limit [°C]           |         0 |       90 |
    };
  };
}
