# DELL omp client: models.yml points ollama at LEGION over the tailnet.
#
# Why: DELL has no GPU worth loading 27B on (Intel HD 520); legion serves
# ollama on 0.0.0.0:11434 with the tailscale0-only firewall open
# (modules/hosts/lenovo-legion-16iah7h-PF3XJ8SP/private/dev/agentics/ollama.nix,
# 2026-09-16 moonlight-era plan). MagicDNS resolves the host
# (lenovo-legion-16iah7h-pf3xj8sp.taild3be63.ts.net, verified 2026-09-20),
# but the bare name is enough and keeps working if the tailnet is renamed.
#
# Only the ollama provider: cloud providers (orcarouter/tabitoken/codev)
# need API keys, and DELL has no agenix identity enrolled — keys are
# legion-only. /model still lists the cloud providers' names via omp's
# implicit discovery? No: models.yml REPLACES the catalog, so DELL users
# get exactly ollama. sessionVariables/pi-reasonix extension come from the
# shared dev.agentics.harnesses.oh-my-pi aspect; this file only pins hosts
# and windows.
{den, ...}: {
  den.aspects.dell-latitude-E7270-H836QF2 = {
    homeManager = {
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      models = {
        providers = {
          # Legion's daemon over the tailnet. Same contextWindow pin as
          # legion's own client (q4_0 KV makes 131072 fit the 3090; see
          # ollama.nix) — omp's bundled ollama catalog claims 262144 and
          # would ride past the real window into ollama's trim, dropping
          # the original user turn (ollama #17778 retry loop).
          ollama = {
            baseUrl = "http://lenovo-legion-16iah7h-pf3xj8sp:11434";
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
    in {
      home.file.".omp/agent/models.yml".source =
        yaml.generate ".omp.agent.models.yml" models;
    };
  };
}
