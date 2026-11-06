# LEGION memdoor client & wrapper: configured to point at the local
# ninfer engine (:8092) mirroring the ompl harness pattern.
#
# Memdoor is configured with:
#   1. ~/.memdoor/providers.json defining the local keyless ninfer provider
#      serving the canonical Qwen variants.
#   2. `memdoorl` wrapper script synchronizing dynamically with the active
#      ninfer model via `ninfer active` (fallback: qwen3.8-27b-turbo),
#      setting AI_GATEWAY_* vendor engine variables to pin turns directly
#      to the local 3090 inference engine without cloud leaks.
{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      pkgs,
      ...
    }: let
      json = pkgs.formats.json {};

      ninferPort = 8092;

      ninferModels = [
        {
          id = "qwen3.8-27b";
          name = "Qwen 3.8 27B";
          context = 65536;
          max_output = 16384;
          inputs = ["text" "image"];
          thinking = true;
        }
        {
          id = "qwen3.8-27b-turbo";
          name = "Qwen 3.8 27B Turbo (Heretic)";
          context = 65536;
          max_output = 16384;
          inputs = ["text" "image"];
          thinking = true;
        }
        {
          id = "qwen3.6-35b-a3b";
          name = "Qwen 3.6 35B A3B (Vision)";
          context = 65536;
          max_output = 16384;
          inputs = ["text" "image"];
          thinking = true;
        }
        {
          id = "qwen3.6-35b-a3b-abliterated";
          name = "Qwen 3.6 35B A3B (Abliterated)";
          context = 65536;
          max_output = 16384;
          inputs = ["text" "image"];
          thinking = true;
        }
      ];

      providersConfig = {
        providers = [
          {
            id = "ninfer";
            name = "ninfer";
            api = "chat";
            base = "http://127.0.0.1:${toString ninferPort}/v1";
            key = "";
            keyless = true;
            models = ninferModels;
          }
        ];
      };

      # memdoorl wrapper: dynamically queries active model via `ninfer active`
      # (matching omplWrapper in oh-my-pi.nix), pins the active model into
      # ~/.memdoor/model.json (persistent pin schema per gateway/persistent_pin.go:41-43),
      # and launches memdoor.
      memdoorlWrapper = pkgs.writeShellScriptBin "memdoorl" ''
        set -euo pipefail

        active_model="$( ninfer active 2>/dev/null || true )"
        active_model="''${active_model:-qwen3.8-27b-turbo}"

        memdoor_dir="''${HOME}/.memdoor"
        mkdir -p -m 0700 "$memdoor_dir"

        model_json="$memdoor_dir/model.json"
        cat << EOF > "$model_json.tmp"
{
  "by_actor": {
    "": {
      "model": "ninfer/$active_model"
    }
  }
}
EOF
        chmod 600 "$model_json.tmp"
        mv "$model_json.tmp" "$model_json"

        exec memdoor "$@"
      '';
    in {
      home.packages = [
        memdoorlWrapper
      ];

      # force = true self-heals over pre-existing files so HM activation succeeds.
      home.file.".memdoor/providers.json" = {
        source = json.generate "memdoor-providers.json" providersConfig;
        force = true;
      };
    };
  };
}
