{ pkgs, ... }:

{
  systemd.services.pocketbase = {
    script = "${pkgs.pocketbase}/bin/pocketbase serve --encryptionEnv=PB_ENCRYPTION_KEY --dir /path/to/pb_data";
    serviceConfig = {
      LimitNOFILE = 4096;
      EnvironmentFile = ["/path/to/secret"];
    };
    wantedBy = [ "multi-user.target" ];
  };

  # You can replace caddy with another reverse proxy (or none, albeit generally not recommended) if wanted
  services.caddy = {
    enable = true;
    virtualHosts = {
      "pocketbase.example.com".extraConfig = ''
        request_body {
          max_size 10MB
        }
        reverse_proxy 127.0.0.1:8090 {
          transport http {
            read_timeout 360s
          }
        }
      '';
    };
  };
}
