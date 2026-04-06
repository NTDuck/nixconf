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
  appId = "1973530"; # Limbus Company Steam AppID

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

      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      if [ ! -f "$APP_DIR/vcrun2022_installed" ]; then
        echo "Injecting vcrun2022 into Limbus Company Proton prefix..."
        ${pkgs.steam-run}/bin/steam-run ${pkgs.protontricks}/bin/protontricks -c "winetricks -q vcrun2022" ${appId}
        touch "$APP_DIR/vcrun2022_installed"
      fi

      echo "Running AALC inside Limbus Company's environment..."
      # Launch AALC directly via Proton so it shares the same Wine Server as the game
      exec ${pkgs.steam-run}/bin/steam-run ${pkgs.protontricks}/bin/protontricks -c "wine \"$EXE_PATH\"" ${appId}
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

  wayland.windowManager.sway.config = {
    # ... your existing configuration ...

    window = {
      commands = [
        # Force all Wine windows to float. This stops Sway from tiling
        # the invisible shadow/layout boxes generated by WPF and .NET apps.
        {
          criteria = {class = "Wine";};
          command = "floating enable";
        }
        {
          criteria = {class = "wine";};
          command = "floating enable";
        }
      ];
    };
  };
}
