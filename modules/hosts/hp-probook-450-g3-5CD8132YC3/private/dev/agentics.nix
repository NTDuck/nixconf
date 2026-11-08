# HP ProBook omp harness + local BitNet engine (2026-11-08):
# CPU-only worker (i7-6500U, 4T/7GB, no discrete GPU). Serves the
# BitNet-b1.58-2B-4T i2_s GGUF via bitnet.cpp's llama-server fork —
# benchmarked fastest CPU decode on this host (17.5 tok/s t4 vs 2.1
# Qwen3-1.7B / 3.4 LFM2, benchmarks/INFERENCE-ENGINES.md).
#
# ENGINE SOURCE (NOT NIX-MANAGED): bitnet.cpp lives at ~/src/BitNet on
# HP, copied as a plain tree (no .git) with 4 upstream bugs worked
# around during the 2026-11-08 build session (see INFERENCE-ENGINES.md
# "CPU-only host" section). Repinning it declaratively needs a
# fetchgit + those patches ported into Nix phases; until then the
# service points at the on-disk build. Same shape as legion's
# ninferRoot pointing at ~/models/q27-bench (plain home dir).
#
# omp wiring mirrors dell/legion (host-private harnesses/oh-my-pi.nix):
# models.yml REPLACES omp's implicit catalog — without a local provider
# entry /model lists NO local models. HP carries no cloud providers and
# no agenix secrets: this is a fully local harness (the point of a
# headless worker). Effort suffix (:high) is omitted from modelRoles —
# bitnet is non-reasoning and the catalog has no effort levels for it
# (legion pins :high only on reasoning models).
{
  inputs,
  lib,
  ...
}: {
  den.aspects.hp-probook-450-g3-5CD8132YC3 = {
    nixos = {pkgs, ...}: let
      bitnetRoot = "/home/ayin/src/BitNet";
      modelPath = "/home/ayin/models/gguf/BitNet-b1.58-2B-4T/ggml-model-i2_s.gguf";
      bitnetPort = 8910;
    in {
      systemd.services.bitnet-server = {
        description = "BitNet b1.58-2B-4T i2_s (bitnet.cpp llama-server, CPU)";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          User = "ayin";
          Group = "users";
          # -c 4096: model's n_ctx_train is 4096 (/v1/models,
          # live-verified 2026-11-08) — don't exceed it.
          # -t 4: all P-cores (i7-6500U); more threads regressed tg64.
          # -fa on: flash-attn, smoke-verified coherent output.
          # --alias bitnet-b1.58-2b: stable /v1/models id (otherwise the
          # id is the absolute model path).
          ExecStart = pkgs.writeShellScript "bitnet-server-start" ''
            export LD_LIBRARY_PATH="${bitnetRoot}/build/bin"
            exec "${bitnetRoot}/build/bin/llama-server" \
              -m "${modelPath}" \
              --host 127.0.0.1 --port ${toString bitnetPort} \
              -c 4096 -t 4 -fa on --alias bitnet-b1.58-2b
          '';
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };

    homeManager = {
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      bitnetPort = 8910;
      bitnetProvider = {
        baseUrl = "http://127.0.0.1:${toString bitnetPort}/v1";
        api = "openai-completions";
        auth = "none";

        models = [
          {
            id = "bitnet-b1.58-2b";
            name = "BitNet b1.58 2B 4T (i2_s, CPU)";
            reasoning = false;
            input = ["text"];
            # Server -c 4096 == n_ctx_train.
            contextWindow = 4096;
            maxTokens = 2048;
          }
        ];
      };

      models = {
        providers = {
          bitnet = bitnetProvider;
        };
      };

      # Default `omp` roles: every role pinned to the local BitNet
      # engine so headless sessions never fall into the setup wizard
      # (models.yml has no cloud fallback by design).
      rolesOverlay = {
        modelRoles = {
          default = "bitnet/bitnet-b1.58-2b";
          smol = "bitnet/bitnet-b1.58-2b";
          slow = "bitnet/bitnet-b1.58-2b";
          plan = "bitnet/bitnet-b1.58-2b";
          commit = "bitnet/bitnet-b1.58-2b";
          task = "bitnet/bitnet-b1.58-2b";
          judge = "bitnet/bitnet-b1.58-2b";
        };
      };

      # `ompl` = stateless scratchpad profile (~/.omp/profiles/ompl/agent):
      # no memory, no autolearn, engine-down fails loudly. Mirrors
      # legion/dell's ompl; no pi-reasonix extension in the profile —
      # it activates only for deepseek-* model ids and this host has none.
      omplOverlay = {
        modelRoles = {
          default = "bitnet/bitnet-b1.58-2b";
          smol = "bitnet/bitnet-b1.58-2b";
          slow = "bitnet/bitnet-b1.58-2b";
          plan = "bitnet/bitnet-b1.58-2b";
          commit = "bitnet/bitnet-b1.58-2b";
          task = "bitnet/bitnet-b1.58-2b";
          judge = "bitnet/bitnet-b1.58-2b";
        };

        enabledModels = ["bitnet/bitnet-b1.58-2b"];
        disabledProviders = [
          # implicit keyless local probes
          "llama.cpp"
          "lm-studio"
          "apple"
          # env-var/stored-credential cloud ids
          "litellm"
          "openrouter"
          "opencode-go"
          "opencode-zen"
          "google-antigravity"
          "openai-codex"
        ];

        retry.modelFallback = false;

        memory.backend = "off";
        autolearn.enabled = false;
      };
    in {
      home.file.".omp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.models.yml" models;
        force = true;
      };
      home.file.".omp/agent/roles.yml" = {
        source = yaml.generate ".omp.agent.roles.yml" rolesOverlay;
        force = true;
      };
      home.file.".omp/agent/ompl.yml" = {
        source = yaml.generate ".omp.agent.ompl.yml" omplOverlay;
        force = true;
      };

      # --- ompl profile support files (~/.omp/profiles/ompl/agent/) ---
      home.file.".omp/profiles/ompl/agent/models.yml" = {
        source = yaml.generate ".omp.agent.ompl-models.yml" {
          providers.bitnet = bitnetProvider;
        };
        force = true;
      };
      home.file.".omp/profiles/ompl/agent/keybindings.yml" = {
        text = ''
          keybindings:
            app.clipboard.pasteImage: "alt+v"
        '';
        force = true;
      };

      home.shellAliases = {
        # mkForce over the shared aspect's mkDefault alias: adds the
        # roles.yml overlay so omp boots straight onto the local engine.
        omp = lib.mkForce (lib.removeSuffix "\n" ''
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/roles.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp
        '');

        # Static modelRoles (single model on the engine — no dynamic
        # active-model query needed, unlike legion/dell's wrapper).
        ompl = lib.removeSuffix "\n" ''
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp --profile ompl
        '';
      };
    };
  };
}
