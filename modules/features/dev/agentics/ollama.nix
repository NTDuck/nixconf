{den, ...}: {
  den.aspects.dev.agentics.ollama = {
    nixos = {
      lib,
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
        path = [ pkgs.unstable.ollama pkgs.curl ];
        script = ''
          ADAPTER_DIR="/var/lib/ollama/adapters/gemma4-opus"
          mkdir -p "$ADAPTER_DIR"
          cd "$ADAPTER_DIR"
          
          if [ ! -f adapter_model.safetensors ]; then
            echo "Downloading adapter config..."
            curl -s -L -o adapter_config.json https://huggingface.co/kai-os/gemma4-31b-Opus-4.6-reasoning/resolve/main/adapter_config.json
            echo "Downloading adapter model safetensors..."
            curl -L -o adapter_model.safetensors https://huggingface.co/kai-os/gemma4-31b-Opus-4.6-reasoning/resolve/main/adapter_model.safetensors
          fi
          
          cat > Modelfile <<EOF
          FROM google/gemma-4-31B-it
          ADAPTER .
          EOF
          
          echo "Building model gemma4-opus in Ollama..."
          ollama create gemma4-opus -f Modelfile
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "ollama";
          Group = "ollama";
        };
      };
    };
  };
}
