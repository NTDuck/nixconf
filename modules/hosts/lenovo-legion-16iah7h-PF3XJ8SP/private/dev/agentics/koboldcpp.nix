# KoboldCpp (v1.124.2 prebuilt binary, bundled CUDA/cuBLAS) — Roleplaying backend
#
# Target host: Lenovo Legion (RTX 3090 TB4 eGPU, 24GB VRAM).
# HOMELAB-ONLY: lives inside specialisation.homelab.configuration (mirrors ninfer.nix
# and prism/default.nix). The 3090 is absent when undocked.
#
# WHY PREBUILT RELEASE BINARY (v1.124.2 koboldcpp-linux-x64):
# Compiling CUDA builds with cublasSupport=true in the Nix sandbox cascades into
# nodejs test failures and multi-hour unfree builds (precedent in llama-cpp.nix).
# The prebuilt binary bundles tested CUDA 12 / cuBLAS / Vulkan kernels, wrapped
# in an FHS environment with host NVIDIA driver access.
#
# MODELS (Roleplaying 24B class):
# Default: Cydonia-24B-v4.3 (TheDrummer/Cydonia-24B-v4.3-GGUF, Q4_K_M quant, 14.33 GB)
# Alternative: Magidonia-24B-v4.3 (TheDrummer/Magidonia-24B-v4.3-GGUF, Q4_K_M quant, 14.33 GB)
# At 14.33 GB weights + 16k KV context (~6-7 GB), it fits fully into 24 GB VRAM.
# KoboldCpp router mode (--routermode + --admindir) allows live hotswapping between
# Cydonia and Magidonia from SillyTavern and RisuAI model selectors.
#
# SHARED BACKEND INTEGRATION:
# - SillyTavern (container): connects via http://host.docker.internal:5001 or http://127.0.0.1:5001
# - RisuAI (native desktop): connects via http://127.0.0.1:5001
# Both frontends consume this single backend on port 5001.
#
# 3090 ARBITRATION:
# Mutual exclusion via Conflicts= against ninfer and bonsai2 daemons.
# On-demand daemon: resident engine on homelab spec is ninfer-df2; starting koboldcpp
# natively stops ninfer via systemd Conflicts; `koboldcpp-down` restores ninfer.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    nixos = {
      pkgs,
      lib,
      config,
      ...
    }: let
      koboldcppPort = 5001;
      modelsDir = "/var/lib/koboldcpp/models";

      # Upstream GitHub release binary (v1.124.2).
      # Pinned release asset with embedded CUDA 12 / cuBLAS.
      koboldcppSrc = pkgs.fetchurl {
        url = "https://github.com/LostRuins/koboldcpp/releases/download/v1.124.2/koboldcpp-linux-x64";
        hash = "sha256-xmrgEGZzx9nEG6/MkslbxaYlZwnp2FPl4iVb9TbBsGk=";
        curlOptsList = ["--http1.1"];
      };

      koboldcppBin = pkgs.runCommand "koboldcpp-bin" {} ''
        mkdir -p $out/bin
        cp ${koboldcppSrc} $out/bin/koboldcpp-unwrapped
        chmod +x $out/bin/koboldcpp-unwrapped
      '';

      # FHS wrapper providing glibc, standard C++ runtimes, and access to NVIDIA driver libraries.
      koboldcppFhs = pkgs.buildFHSEnv {
        name = "koboldcpp";
        targetPkgs = pkgs: with pkgs; [
          stdenv.cc.cc.lib
          glibc
          zlib
          openssl
          curl
        ];
        profile = ''
          export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        '';
        runScript = "${koboldcppBin}/bin/koboldcpp-unwrapped";
      };

      # Script to fetch, resume, verify, and symlink Cydonia and Magidonia GGUFs.
      koboldcppFetchModels = pkgs.writeShellScriptBin "koboldcpp-fetch-models" ''
        set -euo pipefail

        TARGET="''${1:-all}"
        MODELS_DIR="${modelsDir}"
        mkdir -p "$MODELS_DIR"

        CYDONIA_URL="https://huggingface.co/TheDrummer/Cydonia-24B-v4.3-GGUF/resolve/main/Cydonia-24B-v4zg-Q4_K_M.gguf"
        CYDONIA_FILE="Cydonia-24B-v4zg-Q4_K_M.gguf"
        CYDONIA_HASH="1df364399168f94e32af74a5794617b922b1db7590658a6823c65286c49812d6"
        CYDONIA_LINK="Cydonia-24B-v4.3.gguf"

        MAGIDONIA_URL="https://huggingface.co/TheDrummer/Magidonia-24B-v4.3-GGUF/resolve/main/Cydonia-24B-v4zk-Q4_K_M.gguf"
        MAGIDONIA_FILE="Cydonia-24B-v4zk-Q4_K_M.gguf"
        MAGIDONIA_HASH="657d81e69ce57d136c5565a2277590be2125c2840efd7a3814f5b44860796edb"
        MAGIDONIA_LINK="Magidonia-24B-v4.3.gguf"

        download_model() {
          local name="$1"
          local url="$2"
          local file="$3"
          local expected_hash="$4"
          local link="$5"

          local dest="$MODELS_DIR/$file"
          echo "=== Processing $name ==="
          if [ -f "$dest" ]; then
            echo "Checking existing $dest..."
            local current_hash
            current_hash="$(${pkgs.coreutils}/bin/sha256sum "$dest" | ${pkgs.gawk}/bin/awk '{print $1}')"
            if [ "$current_hash" = "$expected_hash" ]; then
              echo "Hash verified: $dest matches expected $expected_hash."
            else
              echo "Hash mismatch for $dest ($current_hash vs $expected_hash). Re-downloading..."
              ${pkgs.curl}/bin/curl -L -C - --http1.1 --retry 5 -o "$dest" "$url"
            fi
          else
            echo "Downloading $name to $dest..."
            ${pkgs.curl}/bin/curl -L -C - --http1.1 --retry 5 -o "$dest" "$url"
            echo "Verifying checksum..."
            local current_hash
            current_hash="$(${pkgs.coreutils}/bin/sha256sum "$dest" | ${pkgs.gawk}/bin/awk '{print $1}')"
            if [ "$current_hash" != "$expected_hash" ]; then
              echo "ERROR: Downloaded $file failed checksum check!" >&2
              exit 1
            fi
          fi

          ln -sfn "$dest" "$MODELS_DIR/$link"
          echo "Symlinked $MODELS_DIR/$link -> $dest"
        }

        case "$TARGET" in
          cydonia|default)
            download_model "Cydonia-24B-v4.3 (Default)" "$CYDONIA_URL" "$CYDONIA_FILE" "$CYDONIA_HASH" "$CYDONIA_LINK"
            ;;
          magidonia)
            download_model "Magidonia-24B-v4.3" "$MAGIDONIA_URL" "$MAGIDONIA_FILE" "$MAGIDONIA_HASH" "$MAGIDONIA_LINK"
            ;;
          all)
            download_model "Cydonia-24B-v4.3 (Default)" "$CYDONIA_URL" "$CYDONIA_FILE" "$CYDONIA_HASH" "$CYDONIA_LINK"
            download_model "Magidonia-24B-v4.3" "$MAGIDONIA_URL" "$MAGIDONIA_FILE" "$MAGIDONIA_HASH" "$MAGIDONIA_LINK"
            ;;
          *)
            echo "Usage: koboldcpp-fetch-models [cydonia|magidonia|all]" >&2
            exit 1
            ;;
        esac

        chmod 0755 "$MODELS_DIR" 2>/dev/null || true
        echo "Done. Models ready in $MODELS_DIR for KoboldCpp router mode."
      '';

      # Service launcher script: chooses default Cydonia model if present, or --nomodel.
      koboldcppLauncher = pkgs.writeShellScriptBin "koboldcpp-launcher" ''
        models_dir="${modelsDir}"
        model_args="--nomodel"

        if [ -f "$models_dir/Cydonia-24B-v4.3.gguf" ]; then
          model_args="--model $models_dir/Cydonia-24B-v4.3.gguf"
        elif [ -f "$models_dir/Cydonia-24B-v4zg-Q4_K_M.gguf" ]; then
          model_args="--model $models_dir/Cydonia-24B-v4zg-Q4_K_M.gguf"
        fi

        exec ${koboldcppFhs}/bin/koboldcpp \
          $model_args \
          --port ${toString koboldcppPort} \
          --host 0.0.0.0 \
          --usecuda 0 \
          --gpulayers -1 \
          --contextsize 16384 \
          --flashattention \
          --smartcontext \
          --admindir "$models_dir" \
          --routermode \
          --adminunloadtimeout 600 \
          --skiplauncher
      '';
    in {
      specialisation.homelab.configuration = {
        systemd.services.koboldcpp = {
          description = "KoboldCpp inference engine (roleplaying backend, Cydonia & Magidonia 24B)";
          after = ["network-online.target"];
          wants = ["network-online.target"];

          # Mutual exclusion with 3090 daemons: starting koboldcpp cleanly stops
          # whichever resident engine holds the card.
          conflicts = [
            "ninfer-df2.service"
            "ninfer-df2-abliterated.service"
            "ninfer-35b.service"
            "ninfer-35b-abliterated.service"
            "ninfer-hemmingway-1-heretic.service"
            "bonsai2.service"
          ];

          # On-demand unit (ninfer-df2 remains resident on homelab spec).
          wantedBy = lib.mkForce [];

          serviceConfig = {
            # Static 3090 pin: CUDA enumerates the mobile 3060 first, so pin by UUID.
            Environment = [
              "CUDA_VISIBLE_DEVICES=GPU-a4e36250-873d-62c5-912e-fde18d238a6c"
              "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
            ];

            # Wait for both nvidia-uvm and the 3090 character node (/dev/nvidia1)
            # to be initialized; avoids racing FLR tunnel link bounce on cold boot.
            ExecCondition =
              "/bin/sh -c 'i=0; until [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia1 ]; do"
              + " i=$((i+1)); [ $i -gt 60 ] && exit 1; ${pkgs.coreutils}/bin/sleep 1; done; exit 0'";

            WorkingDirectory = "/var/lib/koboldcpp";

            # Do NOT set StateDirectory="koboldcpp" (rp.nix precedent): because this unit
            # runs as root, systemd's StateDirectory logic recursively chowns the multi-GB
            # model directory on every unit startup. Create models dir directly in ExecStartPre.
            ExecStartPre = pkgs.writeShellScript "koboldcpp-prestart" ''
              mkdir -p ${modelsDir}
              chmod 0755 /var/lib/koboldcpp ${modelsDir} 2>/dev/null || true
            '';

            ExecStart = "${koboldcppLauncher}/bin/koboldcpp-launcher";

            Restart = "on-failure";
            RestartSec = "5";
            TimeoutStartSec = 120;
          };
        };

        # Passwordless unit state management for koboldcpp.service
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id === "org.freedesktop.systemd1.manage-units" &&
                action.lookup("unit") === "koboldcpp.service" &&
                (subject.isInGroup("wheel") || (subject.local && subject.active))) {
              return polkit.Result.YES;
            }
          });
        '';

        environment.systemPackages = let
          sysd = "${config.systemd.package}/bin/systemctl";
        in [
          koboldcppFhs
          koboldcppFetchModels

          # CLI switcher: start koboldcpp (stops ninfer natively via Conflicts)
          (pkgs.writeShellScriptBin "koboldcpp-up" ''
            set -euo pipefail
            echo "Starting koboldcpp.service on the RTX 3090 (stopping ninfer/bonsai2)..."
            ${sysd} start koboldcpp.service
            for _ in $(seq 1 30); do
              if (exec 3<>"/dev/tcp/127.0.0.1/${toString koboldcppPort}") 2>/dev/null; then
                echo "koboldcpp is ready at http://127.0.0.1:${toString koboldcppPort}"
                exit 0
              fi
              sleep 1
            done
            echo "koboldcpp started; check status with: systemctl status koboldcpp"
          '')

          # CLI switcher: stop koboldcpp and restore resident ninfer
          (pkgs.writeShellScriptBin "koboldcpp-down" ''
            set -euo pipefail
            echo "Stopping koboldcpp.service and restoring ninfer-df2.service..."
            ${sysd} stop koboldcpp.service
            ${sysd} start ninfer-df2.service
            echo "ninfer-df2 restored on the 3090; koboldcpp stopped."
          '')

          # Interactive launcher: connects to / opens KoboldCpp web UI, streaming logs
          (pkgs.writeShellScriptBin "koboldcpp" ''
            port=${toString koboldcppPort}
            if ! ${sysd} is-active --quiet koboldcpp.service 2>/dev/null; then
              echo "koboldcpp.service is not active. Starting via koboldcpp-up..."
              koboldcpp-up
            fi

            for _ in $(seq 1 20); do
              if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then
                ${pkgs.xdg-utils}/bin/xdg-open "http://127.0.0.1:$port" >/dev/null
                echo "koboldcpp: streaming logs — Ctrl+C to stop (server stays running)"
                exec ${pkgs.systemd}/bin/journalctl --no-pager -n 10 -fu koboldcpp.service
              fi
              sleep 0.5
            done
            echo "koboldcpp: http://127.0.0.1:$port not reachable after 10s — check: systemctl status koboldcpp" >&2
            exit 1
          '')
        ];
      };
    };
  };
}
