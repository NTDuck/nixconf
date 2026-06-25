{den, ...}: {
  den.aspects.dev.agentics.ollama = {
    nixos = {
      lib,
      config,
      pkgs,
      ...
    }: {
      services.ollama = {
        enable = true;
        package = pkgs.unstable.ollama;

        syncModels = true;
        loadModels = [
          "gemma4:e2b"
          "gemma4:e4b"
          "mxbai-embed-large"
          "deepseek-r1:32b"
        ];
      };

      systemd.services.ollama-gemma4-opus = {
        description = "Create gemma4-opus model in Ollama using the downloaded adapter";
        after = [ "ollama.service" ];
        requires = [ "ollama.service" ];
        wantedBy = [ "multi-user.target" ];
        environment = config.systemd.services.ollama.environment;
        script = ''
          ADAPTER_DIR="/var/lib/ollama-adapters/gemma4-opus"
          cd "$ADAPTER_DIR"
          
          if [ ! -f adapter_model.safetensors ]; then
            echo "Downloading adapter config..."
            ${pkgs.curl}/bin/curl -s -L -o adapter_config.json https://huggingface.co/kai-os/gemma4-31b-Opus-4.6-reasoning/resolve/main/adapter_config.json
            echo "Downloading adapter model safetensors..."
            ${pkgs.curl}/bin/curl -L -o adapter_model.safetensors https://huggingface.co/kai-os/gemma4-31b-Opus-4.6-reasoning/resolve/main/adapter_model.safetensors
          fi
          
          cat > Modelfile <<EOF
          FROM hf.co/unsloth/gemma-4-31B-it-GGUF:Q4_K_M
          ADAPTER ./adapter_model.safetensors
          EOF
          
          echo "Building model gemma4-opus in Ollama (this will download ~18GB base model GGUF)..."
          ${pkgs.unstable.ollama}/bin/ollama create gemma4-opus -f Modelfile
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "ollama";
          Group = "ollama";
          StateDirectory = "ollama-adapters/gemma4-opus";
          TimeoutStartSec = "infinity";
        };
      };
    };
  };
}
