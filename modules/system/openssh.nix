{
  flake.modules.nixos.openssh = {pkgs, ...}: {
    # `services.gnome.gcr-ssh-agent.enable = true` elsewhere
    # programs.ssh.startAgent = true;

    environment.systemPackages = [
      pkgs.openssh
    ];
  };
}
