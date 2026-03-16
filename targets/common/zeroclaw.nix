{ inputs, system, ... }:

{
  # TODO Don't assume system
  environment.systemPackages = [
    inputs.zeroclaw.packages.${system}.default
  ];
}
