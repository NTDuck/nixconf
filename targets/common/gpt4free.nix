{ ... }:

{
  virtualisation.docker.enable = true;

  # Ensure persistent directories exist with the correct permissions (UID/GID 1000)
  # This allows the container's headless browser to successfully save .har and cookie files.
  systemd.tmpfiles.rules = [
    "d /var/lib/gpt4free 0755 1000 1000 -"
    "d /var/lib/gpt4free/har_and_cookies 0755 1000 1000 -"
    "d /var/lib/gpt4free/generated_images 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers.g4f = {
      image = "hlohaus789/g4f:latest";
      ports = [
        "8080:8080"
        "1337:8080"
        "7900:7900"
      ];
      volumes = [
        "/var/lib/gpt4free/har_and_cookies:/app/har_and_cookies"
        "/var/lib/gpt4free/generated_images:/app/generated_images"
      ];
      extraOptions = [ "--shm-size=2g" ];
      autoStart = false;
    };
  };

  programs.zsh.shellAliases = {
    g4f-start = "sudo systemctl start docker-g4f";
    g4f-stop = "sudo systemctl stop docker-g4f";
  };
}
