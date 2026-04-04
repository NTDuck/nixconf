{ ... }:

{
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
      extraOptions = [ "--shm-size=2g" ];
      autoStart = false;
    };
  };
}
