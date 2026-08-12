{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {pkgs, ...}: let
      ollama-cuda-patched =
        pkgs.unstable.ollama-cuda.overrideAttrs
        (old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or [])
            ++ [
              pkgs.unstable.cudaPackages.cuda_nvcc
            ];

          # The updated CUDA setup hook gives the nested llama.cpp CMake
          # project an invalid CUDAToolkit_ROOT. CMake then refuses to search
          # PATH for nvcc. Remove that value and explicitly provide nvcc before
          # ollama-cuda's preBuild runs its nested CMake build.
          preBuild =
            ''
              unset CUDAToolkit_ROOT

              export CUDACXX="${pkgs.unstable.cudaPackages.cuda_nvcc}/bin/nvcc"
              export PATH="${pkgs.unstable.cudaPackages.cuda_nvcc}/bin:$PATH"

              if [[ ! -x "$CUDACXX" ]]; then
                echo "CUDA compiler does not exist: $CUDACXX" >&2
                exit 1
              fi

              echo "Using CUDA compiler: $CUDACXX"
            ''
            + (old.preBuild or "");
        });
    in {
      services.ollama = {
        enable = true;
        # package = pkgs.unstable.ollama-cuda;
        package = ollama-cuda-patched;

        host = "127.0.0.1";
        port = 11434;

        loadModels = [
          # `npx llm-checker recommend`
          "mistral:7b-instruct-v0.2-q5_0" # overall, general
          "qwen2.5-coder:7b-base-q5_0" # coding
          "qwen2.5:7b-instruct-q5_0" # reasoning
          "llava:7b-v1.6-mistral-q5_0" # multimodal
          "deepseek-r1:7b" # creative, chat
          "yi:6b-200k-q3_K_S" # reading

          # Dense, coding
          "qwen3.5:4b-q4_K_M"
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL"
          "hf.co/unsloth/Qwen3-4B-Instruct-2507-GGUF:Q5_K_M"

          # MoE, reasoning
          "lfm2.5:8b-a1b-q4_K_M"
          "gpt-oss:20b"
          "qwen3:30b"
        ];
        syncModels = true;

        environmentVariables = {
          OLLAMA_FLASH_ATTENTION = "1";
          OLLAMA_KV_CACHE_TYPE = "q4_0";
        };
      };
    };
  };
}
