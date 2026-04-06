# {pkgs, ...}: let
#   version = "1.4.5";
#   runnerUrl = "https://github.com/Kron4ek/Wine-Builds/releases/download/11.5/wine-11.5-staging-amd64.tar.xz";
#   aalc = pkgs.stdenv.mkDerivation {
#     pname = "ahab-assistant-limbus-company";
#     inherit version;
#     src = pkgs.fetchurl {
#       url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
#       hash = "sha256-9Wm2HeIHIm0DyLbeaSimeriy1g2BmGVsLBnrqI5kKp4=";
#     };
#     nativeBuildInputs = [pkgs.p7zip pkgs.makeWrapper];
#     sourceRoot = ".";
#     installPhase = ''
#             mkdir -p $out/opt/aalc
#             cp -r * $out/opt/aalc/
#             mkdir -p $out/bin
#             cat > $out/bin/aalc <<'EOF'
#       #!/bin/sh
#       APP_DIR="$HOME/.local/share/aalc"
#       RUNNER_DIR="$APP_DIR/runner"
#       export WINEPREFIX="$APP_DIR/wineprefix"
#       export WINEDLLOVERRIDES="winemenubuilder.exe=d"
#       mkdir -p "$APP_DIR"
#       if [ "$(cat "$APP_DIR/version" 2>/dev/null)" != "${version}" ]; then
#         echo "Deploying Ahab Assistant version ${version}..."
#         rm -rf "$APP_DIR/app"
#         mkdir -p "$APP_DIR/app"
#         cp -r ${placeholder "out"}/opt/aalc/* "$APP_DIR/app/"
#         chmod -R +w "$APP_DIR/app"
#         echo "${version}" > "$APP_DIR/version"
#       fi
#       EXE_PATH=$(find "$APP_DIR/app" -type f -iname "AALC.exe" | head -n 1)
#       if [ ! -d "$RUNNER_DIR" ]; then
#         echo "Downloading and extracting Kron4ek Wine..."
#         mkdir -p "$RUNNER_DIR"
#         ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
#       fi
#       # Explicitly assign our downloaded Wine to the WINE variable
#       export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)
#       if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
#         echo "Installing vcrun2022 via winetricks..."
#         # Wrap winetricks in steam-run to satisfy dynamic linking
#         ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022
#         touch "$APP_DIR/vcrun2022_installed"
#       fi
#       cd "$(dirname "$EXE_PATH")"
#       # Run inside a Virtual Desktop to stop Sway from tiling hidden WPF overlay windows
#       exec ${pkgs.steam-run}/bin/steam-run "$WINE" explorer /desktop=AALC,1280x720 "$EXE_PATH"
#       EOF
#             chmod +x $out/bin/aalc
#     '';
#   };
#   desktopItem = pkgs.makeDesktopItem {
#     name = "aalc";
#     desktopName = "Ahab Assistant";
#     exec = "aalc";
#     terminal = false;
#     categories = ["Utility"];
#   };
# in {
#   environment.systemPackages = [
#     aalc
#     desktopItem
#   ];
# }
{pkgs, ...}: let
  version = "1.4.5";
  runnerUrl = "https://github.com/Kron4ek/Wine-Builds/releases/download/11.5/wine-11.5-staging-amd64.tar.xz";

  aalc = pkgs.stdenv.mkDerivation {
    pname = "ahab-assistant-limbus-company";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
      hash = "sha256-9Wm2HeIHIm0DyLbeaSimeriy1g2BmGVsLBnrqI5kKp4=";
    };

    nativeBuildInputs = [pkgs.p7zip pkgs.makeWrapper];
    sourceRoot = ".";

    installPhase = ''
            mkdir -p $out/opt/aalc
            cp -r * $out/opt/aalc/
            mkdir -p $out/bin

            cat > $out/bin/aalc <<'EOF'
      #!/bin/sh
      APP_DIR="$HOME/.local/share/aalc"
      RUNNER_DIR="$APP_DIR/runner"
      export WINEPREFIX="$APP_DIR/wineprefix"
      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      # THE FIX: Force XWayland. Native Wayland Wine completely breaks WPF mouse inputs.
      unset WAYLAND_DISPLAY

      mkdir -p "$APP_DIR"

      if [ "$(cat "$APP_DIR/version" 2>/dev/null)" != "${version}" ]; then
        echo "Deploying Ahab Assistant version ${version}..."
        rm -rf "$APP_DIR/app"
        mkdir -p "$APP_DIR/app"
        cp -r ${placeholder "out"}/opt/aalc/* "$APP_DIR/app/"
        chmod -R +w "$APP_DIR/app"
        echo "${version}" > "$APP_DIR/version"
      fi

      EXE_PATH=$(find "$APP_DIR/app" -type f -iname "AALC.exe" | head -n 1)

      if [ ! -d "$RUNNER_DIR" ]; then
        echo "Downloading and extracting Kron4ek Wine..."
        mkdir -p "$RUNNER_DIR"
        ${pkgs.wget}/bin/wget -qO- ${runnerUrl} | ${pkgs.gnutar}/bin/tar -xJ --strip-components=1 -C "$RUNNER_DIR"
      fi

      export WINE=$(find "$RUNNER_DIR" -name "wine" -type f -executable | head -n 1)

      if [ ! -f "$APP_DIR/wpf_fixed" ]; then
        echo "Applying Sway & XWayland compatibility fixes to Wine..."

        ${pkgs.steam-run}/bin/steam-run ${pkgs.winetricks}/bin/winetricks -q vcrun2022

        # Disable WPF Hardware Acceleration to kill the invisible shadow boxes
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Microsoft\Avalon.Graphics" /v DisableHWAcceleration /t REG_DWORD /d 1 /f

        # Tell Wine not to draw native X11 window borders
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d N /f

        # Tell Wine to not let the Window Manager control the window hierarchy (fixes focus stealing)
        ${pkgs.steam-run}/bin/steam-run "$WINE" reg add "HKCU\Software\Wine\X11 Driver" /v Managed /t REG_SZ /d N /f

        touch "$APP_DIR/wpf_fixed"
      fi

      cd "$(dirname "$EXE_PATH")"

      echo "Launching AALC..."
      exec ${pkgs.steam-run}/bin/steam-run "$WINE" "$EXE_PATH"
      EOF

            chmod +x $out/bin/aalc
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "aalc";
    desktopName = "Ahab Assistant";
    exec = "aalc";
    terminal = false;
    categories = ["Utility"];
  };
in {
  environment.systemPackages = [
    aalc
    desktopItem
  ];
}
