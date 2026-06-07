{
  flake.modules.nixos.lix = {inputs, ...}: {
    imports = [inputs.lix-module.nixosModules.default];
  };
}
