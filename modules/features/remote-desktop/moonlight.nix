# moonlight-qt client; pairs with the sunshine host on the Legion over LAN.
#
# HD 520 codec constraint (DELL E7270, Skylake 6th gen): the iGPU has
# H264 hardware decode but NO HEVC, NO AV1, and NO YUV444 support.
# sunshine on Legion defaults to the best codec the client advertises;
# without flags, moonlight-qt requests HEVC and DELL's VAAPI fails to
# decode → black screen or crash.
#
# Solution: replace the upstream moonlight-qt's binary with a wrapper
# that always passes the codec restriction flags. This covers every
# invocation path (spectrwm/dmenu, terminal, remote-specialisation
# cage session — the cage session also passes these flags explicitly
# but the wrapper is harmless there). Legion is unaffected because
# NVIDIA supports every codec the wrapper refuses.
{den, ...}: {
  den.aspects.remote-desktop.moonlight = {
    nixos = {pkgs, ...}: let
      # Wrap moonlight-qt's binary via makeWrapper so the codec
      # restriction flags are prepended to every invocation.
      # overrideAttrs is used because moonlight-qt ships a proper
      # postInstall hook (meson-based) — appending a makeWrapper call
      # keeps the upstream install intact and only wraps the final
      # binary.
      moonlightQt = pkgs.unstable.moonlight-qt.overrideAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ [pkgs.makeWrapper];

        postInstall =
          (old.postInstall or "")
          + ''
            # Wrap the main binary so every invocation gets the HD
            # 520-safe codec flags prepended. Users can still pass
            # additional args; --add-flags inserts before $@.
            wrapProgram $out/bin/moonlight \
              --add-flags "--no-h265 --no-av1 --no-yuv444"
          '';
      });
    in {
      environment.systemPackages = [
        moonlightQt # upstream moonlight-qt with the wrapper applied
      ];
    };
  };
}
