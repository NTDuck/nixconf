# DELL omp client: models.yml points ashalliants at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ashalliants on 0.0.0.0:8092 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ashalliants.nix,
# 2026-10-10 main-engine switch). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# REMOTE SPEC ONLY (2026-09-21 user request, 3090 specialisation pattern): the
# 3090-implied client rides the "remote" specialisation — booting DELL's
# default generation drops the ashalliants entry (models.yml absent; omp
# falls back to implicit catalog discovery). The daemon side is gated
# inside legion's homelab specialisation; both specs must exist for the
# tailscale workflow to work.
#
# Only the ashalliants provider: cloud providers (orcarouter/tabitoken/codev)
# need API keys, and DELL has no agenix identity enrolled — keys are
# legion-only. /model still lists the cloud providers' names via omp's
# implicit discovery? No: models.yml REPLACES the catalog, so DELL users
# get exactly ashalliants. sessionVariables/pi-reasonix extension come
# from the shared dev.agentics.harnesses.oh-my-pi aspect; this file only
# pins hosts and windows.
#
# 2026-10-12: ollama removed entirely (user request — ashalliants is the
# sole local engine). The previous ollama provider block (pointing at
# legion's :11434) is gone; ashalliants is the only local provider.
{
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # 3090 gating: osConfig.isSpecialisation is mkOverride-0 true inside
      # spec evals (nixos/modules/system/activation/no-clone.nix) and false
      # in the default generation, so models.yml is written only when the
      # remote spec boots.
      onRemoteSpec = osConfig.isSpecialisation or false;

      models = {
        providers = {
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
      # `enable = false` drops the entry entirely; an empty attrset would
      # fail ("source was accessed but has no value defined" at HM merge).
      home.file.".omp/agent/models.yml" = {
        enable = onRemoteSpec;
        source = yaml.generate ".omp.agent.models.yml" models;
      };
    };
  };
}
