{ pkgs, ... }:

let
  version = "1.4.5";

  aalc = pkgs.stdenv.mkDerivation {
    pname = "ahab-assistant-limbus-company";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/KIYI671/AhabAssistantLimbusCompany/releases/download/V${version}/AALC_V${version}.7z";
      # Replace this with the actual hash once Nix complains on the first build
      hash = pkgs.lib.fakeHash;
    };

    nativeBuildInputs = [ pkgs.p7zip ];

    # .7z archives don't always have a single root directory, so we unpack in the current dir
    sourceRoot = ".";

    unpackPhase = ''
      7z x $src
    '';

    installPhase = ''
      # Copy the extracted files into the read-only Nix store
      mkdir -p $out/opt/aalc
      cp -r * $out/opt/aalc/

      mkdir -p $out/bin

      # Dynamically find the .exe file in the extracted folder
      EXE_PATH=$(find $out/opt/aalc -type f -name "AALC.exe" | head -n 1)

      # Create the wrapper script that launches it via protontricks
      cat > $out/bin/aalc <<EOF
#!/bin/sh
exec ${pkgs.protontricks}/bin/protontricks-launch --appid 1973530 "\$EXE_PATH"
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
