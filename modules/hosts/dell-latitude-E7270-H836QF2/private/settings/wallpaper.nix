# Dell-specific wallpaper (2026-09-22): the shared stylix aspect
# defaults to 230826-2.png, which noctalia (legion) consumes as its
# fallback too — override here instead of flipping the shared pin.
# The dwm session wrapper's feh paints config.stylix.image.
# mkForce: the shared stylix aspect also defines image (mkDefault);
# two plain definitions conflict at eval.
{
  inputs,
  lib,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    nixos.stylix.image = lib.mkForce "${inputs.self}/assets/wallpapers/isle-of-the-dead.jpg";
  };
}
