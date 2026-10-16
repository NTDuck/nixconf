# DELL omp client: models.yml points ashalliants at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ashalliants on 0.0.0.0:8092 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ashalliants.nix,
# 2026-10-10 main-engine switch). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# MODELS.YML ON ALL SPECS (2026-10-16 user request): ashalliants entry is
# active on the default generation too (previously gated to "remote"
# specialisation), enabling Dell clients to access Qwen 3.8 27B on legion
# over tailnet across all sessions, including ssh.
#
# PROVIDERS (2026-10-16): models.yml carries both the NetMind codev models
# (MiniMax M3, GLM 5.3 Flash) and the legion ashalliants provider (Qwen 3.8 27B).
# sessionVariables/pi-reasonix extension come from the shared
# dev.agentics.harnesses.oh-my-pi aspect; this file pins models and windows.
#
# 2026-10-12: ollama removed entirely (user request — ashalliants is the
# sole local engine). The previous ollama provider block (pointing at
# legion's :11434) is gone; ashalliants is the only local provider.
{
  den,
  inputs,
  lib,
  ...
}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      models = {
        providers = {
          # NetMind CodeV gateway (restored 2026-10-16 per user request).
          codev = {
            baseUrl = "https://netmind.viettel.vn/gateway/v1";
            api = "openai-completions";
            apiKey = "CODEV_API_KEY";
            authHeader = true;

            models = [
              {
                id = "MiniMax/MiniMax-M3";
                name = "MiniMax M3 (NetMind)";
                contextWindow = 196608;
                maxTokens = 65536;
              }
              {
                id = "zai-org/GLM-5.3-Flash";
                name = "GLM 5.3 Flash (NetMind)";
                contextWindow = 1048576;
                maxTokens = 131072;
              }
            ];
          };
          # ashalliants-df2 on legion (port 8092 over tailscale0,
          # 2026-10-10 main-engine switch — legion's RESIDENT 3090 engine,
          # ashalliants.nix). The port MUST match legion's
          # options.services.ashalliants.port (defined in
          # modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ashalliants.nix).
          # Cross-aspect references aren't reliable in the den module
          # system (legion's aspect isn't included on dell), so the port
          # is duplicated here with this comment as the sync point.
          # OpenAI Chat Completions, declared model (no discovery
          # protocol); 262144 = the tuned-profile serving window
          # (NINFER_FALLBACK=off keeps it exact). An overclaim triggers
          # server-side trim loops.
          ashalliants = {
            baseUrl = "http://lenovo-legion-16iah7h-pf3xj8sp:8092/v1";
            api = "openai-completions";
            auth = "none";

            models = [
              {
                id = "qwen3.8-27b";
                name = "Qwen 3.8 27B";
                reasoning = true;
                input = ["text"];
                contextWindow = 262144;
                maxTokens = 16384;
              }
            ];
          };
        };
      };
      # config.default.yml comes from the SHARED aspect unchanged
      # (symbolPreset = "nerd", 2026-09-25 user request "revert back to
      # use symbolPreset = nerd"): no host-private override of
      # .omp/agent/config.default.yml — the shared aspect's
      # home.file definition is the only one, so no mkForce needed.
    in {
      # force = true (2026-10-16): self-heal over any pre-existing unmanaged
      # models.yml on disk (e.g. manual symlinks) so HM activation does not fail.
      home.file.".omp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.models.yml" models;
        force = true;
      };

      # omp wrapper alias (2026-10-16): inject CODEV_API_KEY from agenix decrypted secret
      home.shellAliases = {
        omp = lib.mkForce (lib.removeSuffix "\n" ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path} 2>/dev/null || cat ~/.codev/auth.json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.api_key // empty')" \
          PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp
        '');
      };
    };
  };
}
