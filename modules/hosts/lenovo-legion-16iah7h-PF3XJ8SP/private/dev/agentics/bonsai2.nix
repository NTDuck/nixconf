# Ternary Bonsai 2 27B — local daily model
#
# WHY NOT OLLAMA (verified 2026-09-18): Bonsai 2 packs (PTQ1_0 / PQ2_0) use
# tensor types + a prism.hadamard.* rotated-weight basis that stock ollama
# cannot load — `ollama create` rejects the file outright ("unsupported
# tensor output.weight size overflows"), and the family's F16 pack parses
# but decodes incoherently without the Hadamard transform (mirror-verified:
# https://ollama.com/tobestyledintro/Ternary-Bonsai-2-27B, AGENTS.md of
# PrismML-Eng/Bonsai-demo). The ternary kernels live only in PrismML's
# llama.cpp fork (https://github.com/PrismML-Eng/llama.cpp). So this is a
# second OpenAI-compatible server (llama-server, :8080) beside ollama
# (:11434); consumers: oh-my-pi (bonsai provider, openai-completions) and
# zed (openai provider).
#
# Engine: prebuilt fork binaries, pinned to prism-b10685-7dffb15 (the newest
# tag prism-b10687 ships ONLY Windows assets; b10685 is the last tag with
# linux-cuda-*). CUDA 12.8 build on the host's 13.2 driver verified working
# (smoke test 2026-09-18: 45 tok/s decode via fit-params on the 3060 while
# a game held 4.6/6 GB; correct output). Sampling/flags mirror
# scripts/start_llama_server.sh (bonsai2 profile: -fa on, --jinja, temp
# 1.0, top-p 0.95, top-k 20).
#
# -ngl is DELIBERATELY omitted: the fork's common_fit_params auto-fits GPU
# layers to free device memory at load (explicit -ngl 999 aborts the fit
# and hard-OOMs the 6 GB 3060 under load). Same flag set covers the 3060
# laptop fallback and the 24 GB 3090 eGPU.
#
# -c 196608 (192K, 2026-09-20 user raise from 32K "context too low"):
# measured KV cost on this model is 64 KiB/token (24 heads * 256-dim K+V *
# 64 layers * 2 bytes, unified cache) -> ~11.25 GiB KV at 192K. Budget on
# the 3090: PQ2_0 weights 6.71 GiB + KV 11.25 GiB + mmproj/CUDA ctx ~0.4 GiB
# ~= 18.4 GiB of 24.5 — fits with ~6 GiB headroom; the model's native max
# (262144) would NOT (24 GiB+). The fit-params step still shrinks context
# to what VRAM allows when the 3060 (6 GB) fallback serves instead — log:
# "failed to fit params... n_gpu_layers already set" proves it engages on
# memory pressure.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # HOMELAB-ONLY (2026-09-21 user request, hotspot.nix pattern): the whole
    # Bonsai 2 stack (prism llama-server, weights, service) lives inside
    # specialisation.homelab — absent from the default generation.
    nixos = {pkgs, ...}: let
      # llama-server + libs from the PrismML fork (prebuilt, CUDA 12.8).
      # 167 MB tarball, sha256 computed locally (GitHub publishes none).
      # The binaries link against system glibc but need these runtimes on
      # the wrapper's LD_LIBRARY_PATH (ldd, verified): libstdc++/libgomp
      # (cc.lib), libssl/libcrypto (openssl), libcudart/libcublas (cuda),
      # libcuda.so.1 (driver, /run/opengl-driver/lib).
      prismLlamaCpp = pkgs.stdenvNoCC.mkDerivation {
        pname = "prism-llamacpp";
        version = "prism-b10685-7dffb15";

        src = pkgs.fetchurl {
          url = "https://github.com/PrismML-Eng/llama.cpp/releases/download/prism-b10685-7dffb15/llama-prism-b10685-7dffb15-bin-linux-cuda-12.8-x64.tar.gz";
          sha256 = "sha256-TsFXJwL6P9NZZTUo+lYl/dnHrgLe2rcUbad3Pa5Izyw=";
        };

        installPhase = ''
          mkdir -p $out/lib/prism-llamacpp
          cp -r . $out/lib/prism-llamacpp/
          chmod -R u+w $out/lib/prism-llamacpp
        '';

        dontStrip = true;
        dontPatchELF = true;
        dontAutoPatchelf = true;
      };

      # Runtime deps as a single colon-list for the wrapper.
      prismLibs = pkgs.symlinkJoin {
        name = "prism-llamacpp-libs";
        paths = with pkgs; [
          stdenv.cc.cc.lib
          openssl
          cudaPackages.cuda_cudart
          cudaPackages.libcublas.lib
        ];
      };

      # Wrapped launcher: sets the lib path and execs the real llama-server.
      # Threads left to llama.cpp (auto = physical cores).
      bonsaiLlamaServer = pkgs.writeShellScriptBin "bonsai-llama-server" ''
        export LD_LIBRARY_PATH="${prismLlamaCpp}/lib/prism-llamacpp:${prismLibs}/lib:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        exec "${prismLlamaCpp}/lib/prism-llamacpp/llama-server" "$@"
      '';

      # Weights, pinned via HF lfs.oid (== content sha256, cross-checked by
      # downloading both and sha256sum). PQ2_0 = 2.0-ish bpw speed band
      # (2026-09-20 user switch from PTQ1_0, the 1.75 bpw max-quality band:
      # AGENTS.md) — faster decode for the daily driver at slightly lower
      # quality, and 0.59 GiB more weights for the 3090's KV budget.
      weights = pkgs.fetchurl {
        url = "https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/resolve/main/Ternary-Bonsai-2-27B-PQ2_0.gguf";
        sha256 = "sha256-OQfcFljbH3ipgmv41by43GXbDUZjiJN69X8ilPrmLsE=";
      };
      mmproj = pkgs.fetchurl {
        url = "https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf/resolve/main/Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf";
        sha256 = "sha256-aAft5h1XC7hro0t1ag+hCe3DNmhgTehnxuptjx1jGQM=";
      };

      bonsaiModels = pkgs.runCommand "bonsai2-27b-gguf" {} ''
        mkdir -p $out/share/bonsai2
        cp ${weights} $out/share/bonsai2/Ternary-Bonsai-2-27B-PQ2_0.gguf
        cp ${mmproj} $out/share/bonsai2/Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf
      '';
      # GPU pin: egpu-adopt/egpu-release rewrite /run/egpu/bonsai.env
      # (renamed 2026-09-20 from ollama.env — ollama is now NixOS-pinned to
      # the 3090 and no longer reads an env file; the two daemons must not
      # be co-resident) and try-restart this unit. '-' prefix: file may not
      # exist yet.
      #
      # PORT 8080, binds 127.0.0.1 only. Port 11434 is ollama; 8080 is the
      # Bonsai-demo default. NOTE: llama-server warns the default port
      # moves to 9931 upstream; we pin 8080 explicitly so that drift is
      # invisible here.
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [
          bonsaiLlamaServer
          bonsaiModels
        ];

        systemd.services.bonsai2 = {
          description = "Bonsai 2 27B llama-server (PrismML fork)";
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];

          serviceConfig = {
            EnvironmentFile = "-/run/egpu/bonsai.env";
            ExecStart = let
              flags = pkgs.lib.concatStringsSep " " [
                "-m ${bonsaiModels}/share/bonsai2/Ternary-Bonsai-2-27B-PQ2_0.gguf"
                "--mmproj ${bonsaiModels}/share/bonsai2/Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf"
                "--host 127.0.0.1"
                "--port 8080"
                "-fa on"
                "-c 196608"
                "--temp 1.0"
                "--top-p 0.95"
                "--top-k 20"
                "--jinja"
                "-np 1"
              ];
            in "+${bonsaiLlamaServer}/bin/bonsai-llama-server ${flags}";
            Restart = "on-failure";
            RestartSec = "5";
            # Model + KV live in VRAM/host RAM; nothing to persist. DynamicUser
            # + ProtectSystem keep the prebuilt-binary daemon sandboxed.
            DynamicUser = true;
            NoNewPrivileges = true;
            ProtectHome = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
          };
        };
      }; # specialisation.homelab.configuration
    };
  };
}
