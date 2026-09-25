# DELL omp client: models.yml points ollama at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ollama on 0.0.0.0:11434 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ollama.nix,
# 2026-09-16 moonlight-era plan). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# REMOTE SPEC ONLY (2026-09-21 user request, hotspot.nix pattern): the
# 3090-implied client rides the "remote" specialisation — booting DELL's
# default generation drops the ollama entry (models.yml absent; omp falls
# back to implicit catalog discovery). The daemon side is gated inside
# legion's homelab specialisation; both specs must exist for the
# tailscale workflow to work.
#
# Only the ollama provider: cloud providers (orcarouter/tabitoken/codev)
# need API keys, and DELL has no agenix identity enrolled — keys are
# legion-only. /model still lists the cloud providers' names via omp's
# implicit discovery? No: models.yml REPLACES the catalog, so DELL users
# get exactly ollama. sessionVariables/pi-reasonix extension come from the
# shared dev.agentics.harnesses.oh-my-pi aspect; this file only pins hosts
# and windows.
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
          # Legion's daemon over the tailnet. Same contextWindow pin as
          # legion's own client (q4_0 KV makes 131072 fit the 3090; see
          # ollama.nix) — omp's bundled ollama catalog claims 262144 and
          # would ride past the real window into ollama's trim, dropping
          # the original user turn (ollama #17778 retry loop).
          ollama = {
            # /v1 REQUIRED (2026-09-21): omp's openai-responses adapter posts
            # <baseUrl>/responses verbatim (no /v1 of its own); ollama serves
            # OpenAI-compat under /v1. Mirrors legion's oh-my-pi.nix fix.
            baseUrl = "http://lenovo-legion-16iah7h-pf3xj8sp:11434/v1";
            api = "openai-responses";
            auth = "none";
            discovery.type = "ollama";
            modelOverrides."qwen3.8:27b-mtp-q4_K_M" = {
              contextWindow = 131072;
              maxTokens = 16384;
            };
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
