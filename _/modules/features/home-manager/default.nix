{ self, inputs, username, ... }:

{
  flake.homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
    # pkgs =
  }
}
