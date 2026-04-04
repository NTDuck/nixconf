{ ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.g4f = {
      image = "hlohaus789/g4f:latest";
      ports = [
        "8080:8080" # Web UI
        "1337:1337" # OpenAI-compatible API
        "7900:7900"
      ];
      autoStart = false;
    };
  };

  programs.zsh.shellAliases = {
    g4f-start = "sudo systemctl start docker-g4f";
    g4f-stop = "sudo systemctl stop docker-g4f";
  };
}
