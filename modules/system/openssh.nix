{
  flake.modules.nixos.openssh = {
    pkgs,
    config,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    # `services.gnome.gcr-ssh-agent.enable = true` elsewhere
    # programs.ssh.startAgent = true;

    environment.systemPackages = [
      pkgs.openssh
    ];
  };
}
