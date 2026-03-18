{ ... }:

{
  imports = [
    ../common  # default.nix

    ./hardware.nix
    ./drivers.nix
  ];
}
