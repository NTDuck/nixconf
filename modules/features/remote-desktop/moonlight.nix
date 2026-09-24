{den, ...}: {
  den.aspects.remote-desktop.moonlight = {
    nixos = {pkgs, ...}: let
      moonlightQt = pkgs.unstable.moonlight-qt.overrideAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ [ pkgs.perl ];

        postPatch =
          (old.postPatch or "")
          + ''
            # Intel HD 520 / Skylake:
            # Force H.264 and disable YUV 4:4:4.

            substituteInPlace app/settings/streamingpreferences.cpp \
              --replace-fail \
                'enableYUV444 = settings.value(SER_YUV444, false).toBool();' \
                'enableYUV444 = false;'

            perl -0pi -e '
              s{
                videoCodecConfig = static_cast<VideoCodecConfig>\(
                  settings\.value\(SER_VIDEOCFG,\s*
                  static_cast<int>\(VideoCodecConfig::VCC_AUTO\)
                \)\.toInt\(\);
              }{
                videoCodecConfig = VCC_FORCE_H264;
              }xs
            ' app/settings/streamingpreferences.cpp
          '';
      });
    in {
      environment.systemPackages = [
        moonlightQt
      ];
    };
  };
}
