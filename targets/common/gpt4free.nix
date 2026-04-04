{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # The 'd' rules ensure the directories exist.
  # The 'Z' rule recursively forces the ownership to 1200:1201, repairing
  # any folders that were created with the wrong UID during the previous build.
  systemd.tmpfiles.rules = [
    "d /var/lib/gpt4free 0755 1200 1201 -"
    "d /var/lib/gpt4free/har_and_cookies 0755 1200 1201 -"
    "d /var/lib/gpt4free/generated_media 0755 1200 1201 -"
    "Z /var/lib/gpt4free - 1200 1201 -"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers.g4f = {
      image = "hlohaus789/g4f:latest";
      ports = [
        "8080:8080" # Web UI
        "1337:8080" # API Endpoint (Internal 8080 handles both UI and API)
        "7900:7900"
      ];
      volumes = [
        "/var/lib/gpt4free/har_and_cookies:/app/har_and_cookies"
        "/var/lib/gpt4free/generated_media:/app/generated_media"
      ];
      extraOptions = [ "--shm-size=2g" ];
      autoStart = false;
    };
  };
}
