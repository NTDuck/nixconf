# moonlight-qt client; pairs with the sunshine host on the Legion over LAN.
#
# HD 520 codec constraint (DELL E7270, Skylake 6th gen): the iGPU has
# H264 hardware decode but NO HEVC, NO AV1, and NO YUV444 support.
# sunshine on Legion defaults to the best codec the client advertises;
# without flags, moonlight-qt requests HEVC and DELL's VAAPI fails to
# decode → black screen or crash. The wrapper below forces H264/YUV420
# only, which works on both DELL (HD 520) and Legion (NVIDIA, which
# supports everything but doesn't mind the restriction).
{den, ...}: {
  den.aspects.remote-desktop.moonlight = {
    nixos = {pkgs, ...}: let
      # Wrapper that calls moonlight-qt with HD 520-safe codec flags.
      # --no-h265: skip HEVC (HD 520 has no HEVC HW decode)
      # --no-av1:  skip AV1 (HD 520 has no AV1 HW decode)
      # --no-yuv444: skip YUV444 (HD 520 can't decode 4:4:4 chroma)
      moonlightSafe = pkgs.writeShellScriptBin "moonlight" ''
        exec ${pkgs.unstable.moonlight-qt}/bin/moonlight \
          --no-h265 --no-av1 --no-yuv444 "$@"
      '';
    in {
      environment.systemPackages = [
        pkgs.unstable.moonlight-qt
        moonlightSafe # `moonlight` (no -qt) runs the HD 520-safe wrapper
      ];
    };
  };
}
