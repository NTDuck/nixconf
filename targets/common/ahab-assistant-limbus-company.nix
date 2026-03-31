{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.protontricks
    pkgs.curl
    pkgs.jq
    pkgs.p7zip

    (pkgs.writeShellScriptBin "aalc" ''
      set -e

      APP_DIR="$HOME/.local/share/aalc"
      VERSION_FILE="$APP_DIR/current_version.txt"

      mkdir -p "$APP_DIR"

      echo "Checking GitHub for the latest Ahab Assistant release..."

      # Fetch the latest release info from the GitHub API
      LATEST_JSON=$(curl -s https://api.github.com/repos/KIYI671/AhabAssistantLimbusCompany/releases/latest)
      LATEST_TAG=$(echo "$LATEST_JSON" | jq -r '.tag_name')

      # Dynamically find the download URL for the .7z asset
      DOWNLOAD_URL=$(echo "$LATEST_JSON" | jq -r '.assets[] | select(.name | endswith(".7z")) | .browser_download_url' | head -n 1)

      if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
        echo "Error: Could not find a .7z release on GitHub for tag $LATEST_TAG."
        exit 1
      fi

      # Check if we already have the latest version downloaded
      CURRENT_TAG=""
      if [ -f "$VERSION_FILE" ]; then
        CURRENT_TAG=$(cat "$VERSION_FILE")
      fi

      if [ "$CURRENT_TAG" != "$LATEST_TAG" ]; then
        echo "New version found ($LATEST_TAG)! Downloading from $DOWNLOAD_URL..."

        # Clean up old extraction folders
        rm -rf "$APP_DIR/app"
        mkdir -p "$APP_DIR/app"

        # Download the .7z archive
        curl -L "$DOWNLOAD_URL" -o "$APP_DIR/update.7z"

        echo "Extracting archive..."
        ${pkgs.p7zip}/bin/7z x "$APP_DIR/update.7z" -o"$APP_DIR/app" -y > /dev/null

        # Clean up the archive and save the new version tag
        rm "$APP_DIR/update.7z"
        echo "$LATEST_TAG" > "$VERSION_FILE"
        echo "Update complete!"
      else
        echo "Ahab Assistant is up to date ($LATEST_TAG)."
      fi

      # Dynamically find the .exe file no matter how deeply it was nested in the .7z
      EXE_PATH=$(find "$APP_DIR/app" -type f -name "*.exe" | head -n 1)

      if [ -z "$EXE_PATH" ]; then
        echo "Error: No .exe file found inside the extracted archive!"
        exit 1
      fi

      echo "Launching $EXE_PATH in the Limbus Company Proton prefix..."

      # Launch it inside the Proton Prefix (App ID 1973530)
      exec ${pkgs.protontricks}/bin/protontricks-launch --appid 1973530 "$EXE_PATH"
    '')
  ];
}
