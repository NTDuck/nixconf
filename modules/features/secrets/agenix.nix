{
  den,
  inputs,
  ...
}: {
  den.aspects.secrets.agenix = {
    nixos = {pkgs, ...}: {
      imports = [
        inputs.agenix.nixosModules.default
      ];

      environment.systemPackages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      age.secrets."orcarouter-api-key" = {
        file = "${inputs.self}/secrets/orcarouter-api-key.age";
        owner = "ayin";
        mode = "0400";
      };
    };
  };
}
