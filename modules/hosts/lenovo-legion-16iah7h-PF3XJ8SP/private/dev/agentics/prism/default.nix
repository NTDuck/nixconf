# Ternary Bonsai 2 27B on the PrismML llama.cpp fork — restored 2026-09-25
# (user request) after the 9199e92 removal. History of this stack:
#
# WHY NOT OLLAMA (verified 2026-09-18): Bonsai 2 packs (PTQ1_0 / PQ2_0) use
# tensor types + a prism.hadamard.* rotated-weight basis that stock ollama
# cannot load — `ollama create` rejects the file outright ("unsupported
# tensor output.weight size overflows"), and the family's F16 pack parses
# but decodes incoherently without the Hadamard transform. The ternary
# kernels live only in PrismML's llama.cpp fork
# (https://github.com/PrismML-Eng/llama.cpp). Engine: prebuilt fork binaries
# pinned to prism-b10685-7dffb15 (the newest tag prism-b10687 ships ONLY
# Windows assets; b10685 is the last tag with linux-cuda-*). CUDA 12.8 build
# on the host's 13.2 driver verified working (smoke test 2026-09-18: 45
# tok/s via fit-params; correct output). The 9199e92 "could not load"
# comment in this file's history refers to OLLAMA failing on the file, not
# to this fork — the fork loaded it fine the whole time.
#
# 2026-09-25 changes vs the pre-removal stack:
# - NO /run/egpu/bonsai.env tiering: the egpu adopter/release machinery
#   stays deleted (9199e92). The user asked for homelab-spec visibility of
#   the 3090 only, so the unit gets a static CUDA_VISIBLE_DEVICES of the
#   3090 UUID (same pin style as services.ollama in ../ollama.nix) and a
#   static 128K context sized for the 3090. Undocked boots leave the unit
#   stopped anyway (no autostart); starting it undocked fails CUDA init
#   — that is the documented trade-off of a static pin.
# - Context: 128K (LLAMA_ARG_CTX_SIZE=131072), the user's floor
#   ("sufficiently large, 128K or 256K"). KV math (2026-09-20 measured):
#   64 KiB/token unified cache -> 8.0 GiB at 128K. Budget on the 3090:
#   PQ2_0 weights 6.71 GiB + KV 8.0 GiB + mmproj/CUDA ctx ~0.4 GiB ~= 15.1
#   GiB of 24.5 -> ~9 GiB headroom. 256K would be 16 GiB KV + 6.7 weights
#   ~= 23.1 GiB — technically fits an EMPTY 3090 but starves the fit-params
#   margin and cannot co-exist with anything; 128K chosen.
# - Parallelism: -np 8 (user: "enable as much parallelism as possible").
#   -c is the TOTAL window shared across slots by continuous batching, so
#   each of the 8 slots sees 16K; total KV cost is unchanged (a function of
#   -c, not -np). 8 slots at 16K each matches the omp/zed fan-out workload
#   that drove the ollama 65K context earlier.
# - Idle unload (user: "offload automatically after 5 minutes if
#   possible"): the fork HAS a native mechanism — --sleep-idle-seconds
#   (verified in this build's llama-server --help, 2026-09-25; default -1
#   = disabled). After N idle seconds the server enters its sleeping
#   state (handle_sleeping_state -> server_models::unload_all/unload_lru
#   in libllama-server-impl.so), freeing model+KV; the next request
#   triggers "exiting sleeping state" + reload from the OS page cache
#   (~6 s, measured in the 2026-09-20 swap era). 300 = the user's 5
#   minutes. No watchdog needed.
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
      # downloading both and sha256sum; the 06af754 hash-mismatch fix).
      # PQ2_0 = 2.0-ish bpw speed band (2026-09-20 user switch from PTQ1_0,
      # the 1.75 bpw max-quality band: AGENTS.md) — faster decode for the
      # daily driver at slightly lower quality.
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
    in {
      specialisation.homelab.configuration = {
        environment.systemPackages = [
          bonsaiLlamaServer
          bonsaiModels
        ];

        systemd.services.bonsai2 = {
          description = "Bonsai 2 27B llama-server (PrismML fork)";
          # NO AUTOSTART (2026-09-21 user request, kept 2026-09-25): the 27B
          # daemon is a scarce-resource unit — it contends with ollama for
          # the 3090. Started on demand via `llamacpp-prism-up` (which first
          # stops ollama); auto-unloaded by arbiter.bonsai-idle after 5 idle
          # minutes (see module comment).
          wantedBy = [];
          after = ["network-online.target"];
          wants = ["network-online.target"];

          serviceConfig = {
            # Static 3090 pin (2026-09-25, homelab-spec visibility request):
            # explicit UUID, not index — CUDA enumerates the 3060 first
            # (live check 2026-09-20: index 0 = 3060 a81782bc, index 1 = 3090
            # a4e36250). Same UUID as the ollama pin in ../ollama.nix; the
            # two daemons arbitrate via llamacpp-prism-up/-down, never
            # co-resident (15.1 GiB + 18 GiB > 24.5 GiB).
            # DOCK-ONLY TRADE-OFF: undocked the unit fails CUDA init — by
            # design, the 3090 is simply absent.
            Environment = "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c";
            ExecStart = let
              # -c is the TOTAL window, divided across -np slots (llama.cpp
              # continuous batching: a single request is served by ONE slot,
              # so per-request context = c/np). User floor: "128K or 256K"
              # per request; "as much parallelism as possible". 256K total +
              # 2 slots = 2 x 128K requests in flight — the maximum
              # parallelism that keeps the per-request floor. VRAM: KV 64
              # KiB/token x 256K = 16 GiB + PQ2_0 weights 6.71 GiB + mmproj/
              # ctx overhead ~0.4 GiB ~= 23.1 GiB of 24.5 — fits the
              # otherwise-empty 3090 (ollama is stopped by llamacpp-prism-up;
              # the desktop runs on the 3060). Safe fallback if the fit ever
              # trims below the floor: drop to "-np 1" + "--ctx-size
              # 131072" (1 x 128K, ~7.5 GiB less KV).
              flags = pkgs.lib.concatStringsSep " " [
                "-m ${bonsaiModels}/share/bonsai2/Ternary-Bonsai-2-27B-PQ2_0.gguf"
                "--mmproj ${bonsaiModels}/share/bonsai2/Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf"
                "--host 127.0.0.1"
                # PORT 8080, binds 127.0.0.1 only. Port 11434 is ollama; 8080
                # is the Bonsai-demo default. NOTE: llama-server warns the
                # default port moves to 9931 upstream; we pin 8080 explicitly
                # so that drift is invisible here.
                "--port 8080"
                "-fa on"
                "--temp 1.0"
                "--top-p 0.95"
                "--top-k 20"
                "--jinja"
                "-np 2"
                "--ctx-size 262144"
                # Native idle unload (see module comment): sleep = free
                # model+KV after 5 min with no requests; reload on demand.
                "--sleep-idle-seconds 300"
              ];
            in "+${bonsaiLlamaServer}/bin/bonsai-llama-server ${flags}";
            Restart = "on-failure";
            RestartSec = "5";
            # Model + KV live in VRAM; nothing to persist. DynamicUser +
            # ProtectSystem keep the prebuilt-binary daemon sandboxed.
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
