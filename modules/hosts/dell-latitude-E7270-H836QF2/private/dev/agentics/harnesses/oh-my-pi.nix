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
{lib, ...}: {
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

      # SYMBOL PRESET OMITTED (2026-09-25 user request "make ohmypi's
      # defaultConfig omit the symbolPreset = nerd"): dell's
      # config.default.yml regenerates from the SHARED attrset
      # (./_omp-default-config.nix, imported by the shared aspect too)
      # minus the key — legion keeps "nerd", dell gets omp's implicit
      # default. mkForce wins the leaf collision with the shared
      # aspect's home.file definition (same path, different content).
      ompDefaultConfig = removeAttrs (import ../../../../../../features/dev/agentics/harnesses/_omp-default-config.nix) ["symbolPreset"];
    in {
      # `enable = false` drops the entry entirely; an empty attrset would
      # fail ("source was accessed but has no value defined" at HM merge).
      home.file.".omp/agent/models.yml" = {
        enable = onRemoteSpec;
        source = yaml.generate ".omp.agent.models.yml" models;
      };

      home.file.".omp/agent/config.default.yml".source =
        lib.mkForce (yaml.generate ".omp.agent.config.default.yml" ompDefaultConfig);
    };
  };
}
