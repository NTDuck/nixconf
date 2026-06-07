{inputs, ...}: {
  flake.modules.nixos.openssh = {
    pkgs,
    config,
    lib,
    username ? "ayin",
    hostname ? "default",
    ...
  }: {
    # `services.gnome.gcr-ssh-agent.enable = true` elsewhere
    # programs.ssh.startAgent = true;

    environment.systemPackages = [
      pkgs.openssh
    ];
  };
}
