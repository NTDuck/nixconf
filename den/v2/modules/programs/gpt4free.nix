{
  flake.modules.nixos.gpt4free = {
    pkgs,
    config,
    lib,
    ...
  }: let
    username = config.this.username;
    hostname = config.this.hostname;
  in {
    virtualisation.docker.enable = true;
    virtualisation.docker.package = pkgs.unstable.docker_29;

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
