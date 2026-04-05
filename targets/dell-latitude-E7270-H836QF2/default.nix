{...}: {
  imports = [
    ../common # default.nix

    ./battery.nix
    ./hardware.nix
    ./drivers.nix
  ];
}
