# Dendritic Configuration FAQ

## How do I declare hosts?

In the dendritic pattern, hosts are treated as thin compositions of feature imports. You declare a host by creating a new `flake-parts` module (e.g., `den/modules/hosts/my-laptop.nix`) that evaluates the NixOS or Darwin system.

You define the host by adding it directly to `flake.nixosConfigurations`:

```nix
{ inputs, ... }: {
  flake.nixosConfigurations."my-laptop" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Base modules, hardware config, etc.
      ./hardware-configuration.nix
      
      # Import the capabilities/features this host needs
      inputs.self.modules.nixos.sway
      inputs.self.modules.nixos.ssh
      
      # You can also pull in the Home Manager aspects
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.myuser = {
          imports = [
            inputs.self.modules.homeManager.sway
            inputs.self.modules.homeManager.ssh
          ];
          home.stateVersion = "24.05";
        };
      }
    ];
  };
}
```

## How do I make hosts automatically exposed?

Because every file in the `modules/` directory is automatically discovered and evaluated by `import-tree`, simply creating the `flake.nixosConfigurations."hostname"` attribute inside *any* module file will automatically expose that host in the resulting flake outputs.

For example, when `den/modules/hosts/my-laptop.nix` is read by `import-tree`, the `flake.nixosConfigurations` attribute is deep-merged with all other `flake-parts` module outputs. There is no need to manually import `my-laptop.nix` in `flake.nix`. Running `nix flake show` will immediately display `my-laptop` under the `nixosConfigurations` output.
