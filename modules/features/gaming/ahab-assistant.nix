{den, ...}: {
  den.aspects.gaming.ahab-assistant = {
    includes = [
      den.aspects.gaming.wine
      den.aspects.gaming.steam
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: let
      pname = "ahab-assistant";
      version = "1.5.1";

      src = pkgs.fetchurl {
        url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
        hash = "sha256-VC+FawFW/KFV+8QvMn8CwK16wMsuSHywhmMTLKkhce8=";
      };

      launcher = pkgs.writeShellScript "ahab-assistant-launcher" ''
        set -euo pipefail

        # Target Steam AppID for Limbus Company
        APP_ID="1973530"

        # Locate Limbus Company Proton Wine prefix
        find_proton_pfx() {
          if [ -n "''${AALC_WINEPREFIX:-}" ]; then
            echo "$AALC_WINEPREFIX"
            return 0
          fi
          if [ -n "''${WINEPREFIX:-}" ]; then
            echo "$WINEPREFIX"
            return 0
          fi

          local default_paths=(
            "$HOME/.local/share/Steam/steamapps/compatdata/$APP_ID/pfx"
            "$HOME/.steam/steam/steamapps/compatdata/$APP_ID/pfx"
            "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/compatdata/$APP_ID/pfx"
          )

          for p in "''${default_paths[@]}"; do
            if [ -d "$p" ]; then
              echo "$p"
              return 0
            fi
          done

          # Check libraryfolders.vdf if Steam is installed with multiple libraries
          local vdf_files=(
            "$HOME/.local/share/Steam/steamapps/libraryfolders.vdf"
            "$HOME/.steam/steam/steamapps/libraryfolders.vdf"
            "$HOME/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"
          )

          for vdf in "''${vdf_files[@]}"; do
            if [ -f "$vdf" ]; then
              while IFS= read -r line; do
                if [[ "$line" =~ \"path\"[[:space:]]+\"([^\"]+)\" ]]; then
                  local lib_path="''${BASH_REMATCH[1]}"
                  local candidate="$lib_path/steamapps/compatdata/$APP_ID/pfx"
                  if [ -d "$candidate" ]; then
                    echo "$candidate"
                    return 0
                  fi
                fi
              done < "$vdf"
            fi
          done

          # Fallback to isolated prefix in local share
          echo "$HOME/.local/share/ahab-assistant/pfx"
        }

        PFX="$(find_proton_pfx)"
        export WINEPREFIX="$PFX"

        # Setup runtime data directory for user configs and logs
        DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/ahab-assistant"
        mkdir -p "$DATA_DIR"
        mkdir -p "$(dirname "$PFX")"

        # Link immutable bundled assets and binaries into writable data directory
        ln -sfn "@pkg@/share/aalc/AALC.exe" "$DATA_DIR/AALC.exe"
        ln -sfn "@pkg@/share/aalc/_internal" "$DATA_DIR/_internal"
        ln -sfn "@pkg@/share/aalc/assets" "$DATA_DIR/assets"
        ln -sfn "@pkg@/share/aalc/i18n" "$DATA_DIR/i18n"

        cd "$DATA_DIR"

        echo "==> Ahab Assistant for Limbus Company"
        echo "==> Using WINEPREFIX: $WINEPREFIX"
        echo "==> Working Directory: $DATA_DIR"

        # Run AALC through Wine
        exec ${pkgs.unstable.wineWow64Packages.stableFull}/bin/wine "$DATA_DIR/AALC.exe" "$@"
      '';

      desktopItem = pkgs.makeDesktopItem {
        name = "ahab-assistant";
        exec = "ahab-assistant";
        icon = "ahab-assistant";
        comment = "Limbus Company Assistant on PC";
        desktopName = "Ahab Assistant (Limbus Company)";
        genericName = "Game Automation Helper";
        categories = ["Game" "Utility"];
      };

      ahab-assistant = pkgs.stdenv.mkDerivation {
        inherit pname version src;

        nativeBuildInputs = [
          pkgs.p7zip
          pkgs.makeWrapper
        ];

        unpackPhase = ''
          runHook preUnpack
          7z x $src
          runHook postUnpack
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share/aalc
          cp -r AALC/* $out/share/aalc/

          mkdir -p $out/bin
          substitute ${launcher} $out/bin/ahab-assistant \
            --subst-var-by pkg $out
          chmod +x $out/bin/ahab-assistant
          ln -s $out/bin/ahab-assistant $out/bin/aalc

          install -Dm444 AALC/assets/logo/my_icon.png $out/share/icons/hicolor/256x256/apps/ahab-assistant.png
          install -Dm444 ${desktopItem}/share/applications/ahab-assistant.desktop $out/share/applications/ahab-assistant.desktop

          runHook postInstall
        '';

        meta = {
          description = "Ahab Assistant for Limbus Company (AALC) - Automation helper on PC";
          homepage = "https://github.com/KIYI671/AhabAssistantLimbusCompany";
          license = lib.licenses.agpl3Plus;
          mainProgram = pname;
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [
        ahab-assistant
      ];
    };
  };
}
