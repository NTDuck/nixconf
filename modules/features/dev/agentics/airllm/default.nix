{den, ...}: {
  den.aspects.dev.agentics.airllm = {
    nixos = {
      lib,
      config,
      pkgs,
      ...
    }: {
      environment.systemPackages = with pkgs; [
        (python3.withPackages (ps: [
          (ps.buildPythonPackage rec {
            pname = "airllm";
            version = "2.11.0";
            format = "setuptools";

            src = ps.fetchPypi {
              inherit pname version;
              hash = "sha256-YvvRfeAdZM5mfnIpH6hkK/XOIMaP8cqDW50dLtNxhW0=";
            };

            propagatedBuildInputs = with ps; [
              transformers
              accelerate
              peft
              sentencepiece
              scipy
              huggingface-hub
              bitsandbytes
            ];

            doCheck = false;
          })
        ]))
      ];

      # Make models available via ollama
      services.ollama = {
        enable = true;
        loadModels = [
          "deepseek-r1:32b"
        ];
      };
    };
  };
}
