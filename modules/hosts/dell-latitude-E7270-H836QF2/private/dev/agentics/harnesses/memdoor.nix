# DELL memdoor client: points ninfer at LEGION over the tailnet (:8092).
#
# Mirroring the ompl harness pattern on Dell (see oh-my-pi.nix:1-21):
#   1. ~/.memdoor/providers.json points the keyless ninfer provider to legion's
#      tailnet address (http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1).
#   2. `memdoorl` wrapper script sets AI_GATEWAY_* vendor engine variables
#      to route all requests directly to legion's ninfer engine on Qwen 3.8 27B
#      Turbo without requiring local GPU or cloud credentials.
{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {
      pkgs,
      ...
    }: let
      json = pkgs.formats.json {};

      legionNinferUrl = "http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1";

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
      ];

      providersConfig = {
        providers = [
          {
            id = "ninfer";
            name = "ninfer";
            api = "chat";
            base = legionNinferUrl;
            key = "";
            keyless = true;
            models = ninferModels;
          }
        ];
      };

# memdoorl wrapper: points memdoor turns to remote ninfer on legion
# over tailnet, pinning Qwen 3.8 27B Turbo in ~/.memdoor/model.json.
      memdoorlWrapper = pkgs.writeShellScriptBin "memdoorl" ''
        set -euo pipefail

        memdoor_dir="''${HOME}/.memdoor"
        mkdir -p -m 0700 "$memdoor_dir"

        model_json="$memdoor_dir/model.json"
        cat << 'EOF' > "$model_json.tmp"
{
  "by_actor": {
    "": {
      "model": "ninfer/qwen3.8-27b-turbo"
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
