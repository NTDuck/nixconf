{ self, inputs, pkgs, ... }:

{
  flake.nixosConfigurations.dell-latitude-E7270-H836QF2 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.
    ];
  };
}
