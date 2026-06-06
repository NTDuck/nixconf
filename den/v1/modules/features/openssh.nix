{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.openssh = {

  # `services.gnome.gcr-ssh-agent.enable = true` elsewhere
  # programs.ssh.startAgent = true;

  environment.systemPackages = [
    pkgs.openssh
  ];

  };
}
