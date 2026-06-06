{ inputs, pkgs, config, lib, ... }:
{
  flake.modules.nixos.gpt4free = {

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.g4f = {
      image = "hlohaus789/g4f:latest";
      ports = [
        "8080:8080"
        "1337:8080"
        "7900:7900"
      ];
      extraOptions = ["--shm-size=2g"];
      autoStart = false;
    };
  };

  programs.zsh.shellAliases = {
    g4f-start = "sudo systemctl start docker-g4f";
    g4f-stop = "sudo systemctl stop docker-g4f";
  };

  };
}
