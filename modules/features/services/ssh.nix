{den, ...}: {
  den.aspects.services.ssh = {
    nixos = {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = true; # Set to false if using SSH keys
          PermitRootLogin = "no";
        };
        # Optional: change port if needed
        # ports = [ 22 ];
      };

      # Open firewall for SSH
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [22]; # Add 443 if using alternate port
      };
    };
  };
}
