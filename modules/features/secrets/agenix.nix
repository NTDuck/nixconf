{
  den,
  inputs,
  ...
}: {
  den.aspects.secrets.agenix = {
    nixos = {
      lib,
      pkgs,
      ...
    }: let
      mkSecret = secret: {
        file = "${inputs.self}/secrets/${secret}.age";
        owner = "root";
        group = "secrets";
        mode = "0440"; # Readable only by owner and group members
      };
    in {
      imports = [
        inputs.agenix.nixosModules.default
      ];

      environment.systemPackages = [
        (inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          # https://github.com/ryantm/agenix/#overriding-age-binary
          ageBin = "${pkgs.unstable.rage}/bin/rage";
        })
      ];

      users.groups.secrets = {};

      age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

      age.secrets =
        lib.genAttrs [
          "github-personalaccesstoken"
          "opencode-api-key"
          "openrouter-api-key"
          "orcarouter-api-key"
        ]
        mkSecret;
    };

    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["secrets"];
    };
  };
}
