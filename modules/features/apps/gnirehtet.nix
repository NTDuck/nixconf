{den, ...}: {
  # Gnirehtet: reverse tethering for Android over USB (Genymobile).
  # https://github.com/Genymobile/gnirehtet
  #
  # Decision (2026-10-30): Upstream nixpkgs `pkgs.gnirehtet` compiles the Rust host
  # from source and depends on `android-sdk-platform-tools` (flagged unfree).
  # To avoid compile overhead on resource-constrained hosts (Dell) and keep
  # evaluation pure/fast, we inline the official upstream prebuilt Linux x86_64
  # release binary, patchelf against glibc/gcc-lib, bundle `gnirehtet.apk`, and
  # wrap it with `GNIREHTET_APK` pointing to the bundled APK and `android-tools`
  # in PATH. Includes `dev.toolchains.android` for ADB and the `adbusers` group.
  den.aspects.apps.gnirehtet = {
    includes = [
      den.aspects.dev.toolchains.android
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: let
      gnirehtet-pkg = pkgs.stdenv.mkDerivation rec {
        pname = "gnirehtet";
        version = "2.5.1";

        src = pkgs.fetchzip {
          url = "https://github.com/Genymobile/gnirehtet/releases/download/v${version}/gnirehtet-rust-linux64-v${version}.zip";
          hash = "sha256-e1wwMhcco9VNoBUzbEq1ESbkX2bqTOkCbPmnV9CpvGo=";
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
        ];

        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.glibc
        ];

        installPhase = ''
          runHook preInstall
          install -Dm755 gnirehtet $out/bin/.gnirehtet-unwrapped
          install -Dm644 gnirehtet.apk $out/share/gnirehtet/gnirehtet.apk

          makeWrapper $out/bin/.gnirehtet-unwrapped $out/bin/gnirehtet \
            --set GNIREHTET_APK "$out/share/gnirehtet/gnirehtet.apk" \
            --prefix PATH : ${lib.makeBinPath [pkgs.android-tools]}
          runHook postInstall
        '';

        meta = with lib; {
          description = "Reverse tethering for Android over USB";
          homepage = "https://github.com/Genymobile/gnirehtet";
          license = licenses.asl20;
          platforms = ["x86_64-linux"];
          mainProgram = "gnirehtet";
        };
      };
    in {
      environment.systemPackages = [
        gnirehtet-pkg
      ];
    };
  };
}
