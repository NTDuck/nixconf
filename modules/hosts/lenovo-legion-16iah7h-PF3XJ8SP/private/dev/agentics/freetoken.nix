{...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      config,
      pkgs,
      lib,
      ...
    }: let
      cfg = config.services.freetoken;
      cudaToolkit = pkgs.cudaPackages.cudatoolkit;
      cudaNvcc = pkgs.cudaPackages.cuda_nvcc;
      cudaCudart = pkgs.cudaPackages.cuda_cudart;

      freetokenLibs = [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
        cudaToolkit
        cudaCudart
      ];

      freetokenWrapper = pkgs.writeShellScriptBin "ft" ''
        export CUDA_HOME="''${CUDA_HOME:-${cudaToolkit}}"
        export FREETOKEN_ALLOW_CUDA_MISMATCH="''${FREETOKEN_ALLOW_CUDA_MISMATCH:-1}"
        export PATH="${lib.makeBinPath [pkgs.unstable.uv pkgs.unstable.python3 cudaNvcc cudaToolkit pkgs.stdenv.cc pkgs.git pkgs.ninja pkgs.which pkgs.coreutils]}:$PATH"
        export LD_LIBRARY_PATH="${lib.makeLibraryPath freetokenLibs}:/run/opengl-driver/lib:/run/opengl-driver-32/lib:${cudaToolkit}/lib64:${cudaToolkit}/lib:${cudaCudart}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        exec ${pkgs.unstable.uv}/bin/uv tool run --from "freetoken[accel]" ft "$@"
      '';
    in {
      options.services.freetoken = {
        # https://arxiv.org/abs/2608.16157
        enable = lib.mkEnableOption "FreeToken: Efficient Edge-Native MoE Serving with Bandwidth-Adaptive Execution";

        host = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = "Host address to bind FreeToken API server.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 1919;
          description = "Port to bind FreeToken API server.";
        };

        defaultModel = lib.mkOption {
          type = lib.types.str;
          default = "Qwen/Qwen3-30B-A3B";
          description = "Default model checkpoint (HF repo id or local path) to serve in systemd daemon.";
        };

        moeBackend = lib.mkOption {
          type = lib.types.enum ["auto" "offload" "fused" "cpu" "hybrid"];
          default = "auto";
          description = "MoE backend execution mode.";
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "--memory-ratio"
            "0.9"
            "--kv-reserve-tokens"
            "8192"
          ];
          description = "Extra arguments passed to `ft serve`.";
        };

        modelsPreset = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              hf-repo = lib.mkOption {
                type = lib.types.str;
                description = "Hugging Face repo or checkpoint identifier.";
              };
              alias = lib.mkOption {
                type = lib.types.str;
                description = "Alias name for the model.";
              };
              description = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Description or notes for the model.";
              };
            };
          });
          default = {};
          description = "Declarative presets of supported frontier MoE models.";
        };
      };

      config = {
        services.freetoken = {
          enable = true;
          host = "127.0.0.1";
          port = 1919;
          defaultModel = "Qwen/Qwen3-30B-A3B";
          moeBackend = "auto";

          modelsPreset = {
            # MoE, reasoning & coding
            "qwen3:30b-a3b" = {
              hf-repo = "Qwen/Qwen3-30B-A3B";
              alias = "qwen3:30b-a3b";
              description = "Qwen3 30B MoE (3B active), fits in RAM with active params in 6GB VRAM";
            };

            "qwen3.6:35b-a3b" = {
              hf-repo = "Qwen/Qwen3.6-35B-A3B";
              alias = "qwen3.6:35b-a3b";
              description = "Qwen3.6 35B MoE (3B active)";
            };

            "qwen3.5:35b-a3b" = {
              hf-repo = "Qwen/Qwen3.5-35B-A3B";
              alias = "qwen3.5:35b-a3b";
              description = "Qwen3.5 35B MoE (3B active)";
            };

            "gpt-oss:20b" = {
              hf-repo = "openai/gpt-oss-20b";
              alias = "gpt-oss:20b";
              description = "OpenAI gpt-oss 20B MoE (~3.6B active), fits in RAM with active params in 6GB VRAM";
            };

            "gpt-oss:120b" = {
              hf-repo = "openai/gpt-oss-120b";
              alias = "gpt-oss:120b";
              description = "OpenAI gpt-oss 120B MoE";
            };

            "deepseek-v4:flash" = {
              hf-repo = "deepseek-ai/DeepSeek-V4-Flash-0731";
              alias = "deepseek-v4:flash";
              description = "DeepSeek V4 Flash MoE";
            };

            "gemma-4:26b-a4b" = {
              hf-repo = "google/gemma-4-26B-A4B-it";
              alias = "gemma-4:26b-a4b";
              description = "Gemma 4 26B MoE (4B active)";
            };

            "glm-5.2:nvfp4" = {
              hf-repo = "nvidia/GLM-5.2-NVFP4";
              alias = "glm-5.2:nvfp4";
              description = "GLM 5.2 NVFP4 MoE";
            };

            "glm-4.7:nvfp4" = {
              hf-repo = "nvidia/GLM-4.7-NVFP4";
              alias = "glm-4.7:nvfp4";
              description = "GLM 4.7 NVFP4 MoE";
            };

            "minimax-m2.5:nvfp4" = {
              hf-repo = "nvidia/MiniMax-M2.5-NVFP4";
              alias = "minimax-m2.5:nvfp4";
              description = "MiniMax M2.5 NVFP4 MoE";
            };

            "muse-glimmer:30b" = {
              hf-repo = "meta-models/Muse-Glimmer-30B";
              alias = "muse-glimmer:30b";
              description = "Muse Glimmer 30B MoE";
            };
          };
        };

        systemd.services.freetoken = lib.mkIf cfg.enable {
          description = "FreeToken Edge-Native MoE Inference Server";
          wantedBy = ["multi-user.target"];
          after = ["network.target"];

          path = [
            pkgs.unstable.uv
            pkgs.unstable.python3
            cudaNvcc
            cudaToolkit
            pkgs.stdenv.cc
            pkgs.ninja
            pkgs.which
            pkgs.bash
            pkgs.coreutils
            pkgs.git
          ];

          environment = {
            CUDA_HOME = "${cudaToolkit}";
            FREETOKEN_ALLOW_CUDA_MISMATCH = "1";
            LD_LIBRARY_PATH = "${lib.makeLibraryPath freetokenLibs}:/run/opengl-driver/lib:/run/opengl-driver-32/lib:${cudaToolkit}/lib64:${cudaToolkit}/lib:${cudaCudart}/lib";
            HOME = "/var/lib/freetoken";
            HF_HOME = "/var/lib/freetoken/huggingface";
            UV_CACHE_DIR = "/var/lib/freetoken/.cache/uv";
          };

          serviceConfig = {
            Type = "simple";
            StateDirectory = "freetoken";
            WorkingDirectory = "/var/lib/freetoken";
            Restart = "on-failure";
            RestartSec = 5;
            ExecStart = "${freetokenWrapper}/bin/ft serve --model ${cfg.defaultModel} --host ${cfg.host} --port ${toString cfg.port} --moe-backend ${cfg.moeBackend} ${lib.escapeShellArgs cfg.extraArgs}";
          };
        };

        environment.systemPackages = [
          freetokenWrapper
          (pkgs.writeShellScriptBin "freetoken" ''
            exec ${freetokenWrapper}/bin/ft "$@"
          '')
        ];
      };
    };
  };
}
