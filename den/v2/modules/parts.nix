{
  inputs,
  config,
  self,
  lib,
  ...
}: {
  systems = ["x86_64-linux" "aarch64-linux"];

  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  flake.nixosConfigurations = let
    hostModulePrefix = "hosts-";
    specialArgs = {
      inherit inputs;
      outputs = self.outputs;
    };
  in
    config.flake.modules.nixos
    |> lib.filterAttrs (name: _: lib.hasPrefix hostModulePrefix name)
    |> lib.mapAttrs' (name: module: {
      name = lib.removePrefix hostModulePrefix name;
      value = inputs.nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [module];
      };
    });
}
