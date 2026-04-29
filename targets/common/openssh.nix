{pkgs, ...}: {
  programs.ssh.startAgent = true;
  environment.systemPackages = [
    pkgs.openssh
  ];
}
