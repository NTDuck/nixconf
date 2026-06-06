{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.alejandra = {

  environment.systemPackages = [
    inputs.alejandra.defaultPackage.${system}
  ];

  };
}
