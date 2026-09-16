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
          mkdir -p $out/bin $out/share
          # Share everything the app ships as a real dir of symlinks (not one
          # parent symlink) so the polkit actions below can be replaced: the
          # icon lives in share/pixmaps and there is NO share/icons upstream —
          # a dangling share/icons symlink broke buildEnv (system-path
          # "not a directory", 2026-09-15).
          # legion_cli goes next to legion_gui on the system-wide path.
          ln -s ${pkgs.unstable.lenovo-legion}/bin/legion_cli $out/bin/legion_cli
          for entry in ${pkgs.unstable.lenovo-legion}/share/*; do
            ln -s "$entry" "$out/share/$(basename "$entry")"
          done
          # Upstream policies annotate FHS paths (/usr/local/bin,
          # /usr/bin/<tool>) absent on NixOS, so pkexec can never match the
          # actions — the GUI's every root write (powermode, touchpad,
          # winkey, ...) died with "No authentication agent found" +
          # path mismatch. polkit-1's symlink is dropped and a real
          # actions dir holds patched copies (rm through a symlink-to-dir
          # would follow INTO the store and fail with "Is a directory").
          rm $out/share/polkit-1
          mkdir -p $out/share/polkit-1/actions
          for p in ${pkgs.unstable.lenovo-legion}/share/polkit-1/actions/*.policy; do
            # Also force allow_active=yes: the defaults are auth_admin /
            # auth_admin_keep, which prompt for an admin password even when
            # the exec.path annotation matches (journal 2026-09-16).
            sed "s#/usr/local/bin/#/run/current-system/sw/bin/#g; s#/usr/bin/#/run/current-system/sw/bin/#g; s#<allow_active>[a-z_]*</allow_active>#<allow_active>yes</allow_active>#g" \
              "$p" > "$out/share/polkit-1/actions/$(basename "$p")"
          done
        '';
      };
    in {
      environment.systemPackages = [
        legion
        # qt6ct.conf sets style=kvantum; without the style plugin Qt cannot
        # load it directly and legion_gui segfaults (QProxyStyle recursion).
        pkgs.qt6Packages.qtstyleplugin-kvantum
      ];

      # Passwordless elevation for the app's pkexec writes. The GUI shells
      # out to `pkexec legion_cli` with a BARE name (legion.py
      # write_file_with_legion_cli); pkexec's path lookup does not match
      # the .policy exec.path annotation, so polkit falls back to the
      # GENERIC org.freedesktop.policykit.exec action (auth_admin ->
      # password prompt; journal 2026-09-16, "FAILED to authenticate").
      # Grant YES to active local subjects when the action is one of the
      # legion_* actions or the generic exec action for a legion path.
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (!(subject.local && subject.active)) return;
          if (action.id.indexOf("legion") === 0) return polkit.Result.YES;
          var p = action.lookup("org.freedesktop.policykit.exec.path");
          if (p && p.indexOf("legion") !== -1) return polkit.Result.YES;
        });
      '';

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
