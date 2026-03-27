{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.unstable.python3
  ];
}
