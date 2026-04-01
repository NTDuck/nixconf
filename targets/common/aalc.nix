{ pkgs, ... }:

let
  version = "1.4.5";

  aalc = pkgs.stdenv.mkDerivation {
    pname = "ahab-assistant-limbus-company";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
      hash = "sha256-9Wm2HeIHIm0DyLbeaSimeriy1g2BmGVsLBnrqI5kKp4="; # pkgs.lib.fakeHash;
    };

    nativeBuildInputs = [ pkgs.p7zip ];
    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/opt/aalc
      cp -r * $out/opt/aalc/

      mkdir -p $out/bin

      # Note: using <<'EOF' prevents Bash from expanding $HOME during the build phase
      cat > $out/bin/aalc <<'EOF'
#!/bin/sh
APP_DIR="$HOME/.local/share/aalc"
mkdir -p "$APP_DIR"

# If the version changed (or first run), copy the app to a writable location
if [ "$(cat "$APP_DIR/version" 2>/dev/null)" != "${version}" ]; then
  echo "Deploying Ahab Assistant version ${version}..."
  rm -rf "$APP_DIR/app"
  mkdir -p "$APP_DIR/app"

  cp -r ${placeholder "out"}/opt/aalc/* "$APP_DIR/app/"

  # Make the directory writable!
  chmod -R +w "$APP_DIR/app"

  echo "${version}" > "$APP_DIR/version"
fi

EXE_PATH=$(find "$APP_DIR/app" -type f -iname "AALC.exe" | head -n 1)

if [ -z "$EXE_PATH" ]; then
  echo "Error: No .exe file found in $APP_DIR/app"
  exit 1
fi

# We must CD into the directory so Proton/Wine writes local files correctly
cd "$(dirname "$EXE_PATH")"

echo "Launching $EXE_PATH in the Limbus Company Proton prefix..."
exec ${pkgs.protontricks}/bin/protontricks-launch --appid 1973530 "$EXE_PATH"
EOF

      chmod +x $out/bin/aalc
    '';
  };
in
{
  environment.systemPackages = [
    aalc
  ];
}
