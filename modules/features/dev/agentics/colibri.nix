{
  den,
  inputs,
  ...
}: let
  colibriPackage = pkgs:
    inputs.colibri.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      # Upstream's `make test-c` invokes `python3 tools/run_tests.py`; the
      # package did not declare Python, so checkPhase failed in the sandbox.
      nativeBuildInputs =
        (old.nativeBuildInputs or [])
        ++ [
          pkgs.python3
        ];
    });
  colibriServe = pkgs:
    pkgs.writeShellApplication {
      name = "colibri-serve";
      runtimeInputs = [
        (colibriPackage pkgs)
        pkgs.unstable.python3Packages.huggingface-hub
      ];
      text = ''
        model_dir="''${COLI_MODEL:-$HOME/.local/share/colibri/models/GLM-5.2-colibri-int4-with-int8-mtp}"
        marker="$model_dir/.download-complete"

        # The model is hundreds of GB. A marker avoids treating a partially
        # created directory as a finished Hugging Face download.
        if [ ! -e "$marker" ]; then
          mkdir -p "$model_dir"
          huggingface-cli download mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp --local-dir "$model_dir"
          touch "$marker"
        fi

        export COLI_MODEL="$model_dir"
        exec coli serve \
          --host "''${COLI_HOST:-127.0.0.1}" \
          --port "''${COLI_PORT:-8000}" \
          --model-id "''${COLI_MODEL_ID:-GLM 5.2 [744B]}" \
          --auto-tier \
          "$@"
      '';
    };
in {
  den.aspects.dev.agentics.colibri = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        (colibriPackage pkgs)
        (colibriServe pkgs)
        pkgs.unstable.python3Packages.huggingface-hub
      ];
    };

    homeManager = {pkgs, ...}: {
      systemd.user.services.colibri = {
        Unit = {
          Description = "Colibri GLM-5.2 OpenAI-compatible local API";
          Documentation = "https://github.com/JustVugg/colibri";
        };

        # Colibri is disk-streamed and very slow to cold-start; keep it
        # explicit instead of starting a 744B model on every login.
        Install.WantedBy = [];

        Service = {
          ExecStart = "${colibriServe pkgs}/bin/colibri-serve";
          Restart = "on-failure";
          RestartSec = 30;
        };
      };
    };
  };
}
