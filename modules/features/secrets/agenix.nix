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

      # age.secrets."gemini-default-token".file = "${inputs.self}/secrets/gemini-default-token.age";
      # age.secrets."github-token".file = "${inputs.self}/secrets/github-token.age";
    };

    # homeManager = {config, ...}: {
    #   imports = [
    #     inputs.agenix.homeManagerModules.default
    #   ];

    #   age.identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];

    #   age.secrets."gemini-default-token".file = "${inputs.self}/secrets/gemini-default-token.age";
    #   age.secrets."groq-default-token".file = "${inputs.self}/secrets/groq-default-token.age";
    # };
  };
}
