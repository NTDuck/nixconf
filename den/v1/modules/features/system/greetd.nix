{ den, inputs, ... }:
{
  den.aspects."greetd" = {
    nixos = {
    pkgs,
    config,
    ...
  }: let
    colors = config.lib.stylix.colors.withHashtag;
  };
}
