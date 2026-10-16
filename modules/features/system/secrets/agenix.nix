{
  den,
  inputs,
  ...
}: {
  den.aspects.system.secrets.agenix = {
    nixos = {
      config,
      lib,
      pkgs,
      ...
    }: let
      # Secrets ownership (2026-10-16): all managed secrets are ayin's user API keys.
      # Setting owner = ayin and group = users (0400) avoids Permission denied when
      # sessions lack the new 'secrets' group token before relogging.
      mkSecret = secret: {
        file = "${inputs.self}/secrets/${secret}.age";
        owner = "ayin";
        group = "users";
        mode = "0400";
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

      age.secrets = let
        # Host secrets filter (2026-10-16): Dell only needs codev-api-key;
        # other keys are legion-only, so Dell avoids decrypt failures on activation.
        secretNames =
          if config.networking.hostName == "dell-latitude-E7270-H836QF2"
          then ["codev-api-key"]
          else [
            "codev-api-key"
            "github-personalaccesstoken"
            "opencode-api-key"
            "openrouter-api-key"
            "orcarouter-api-key"
            "tabiai-api-key"
          ];
      in
        lib.genAttrs secretNames mkSecret;
    };

    provides.to-users.nixos = {user, ...}: {
      users.users.${user.userName}.extraGroups = ["secrets"];
    };
  };
}
