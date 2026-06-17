{den, ...}: {
  den.aspects.openssh = {
    nixos = {pkgs, ...}: {
      # `services.gnome.gcr-ssh-agent.enable = true` elsewhere
      # programs.ssh.startAgent = true;

      environment.systemPackages = [
        pkgs.unstable.openssh
      ];
    };
  };
}
