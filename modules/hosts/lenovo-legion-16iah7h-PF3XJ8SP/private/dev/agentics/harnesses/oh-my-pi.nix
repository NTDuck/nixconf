{inputs, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      osConfig,
      pkgs,
      ...
    }: {
      home.file.".omp/agent/models.yml".text = ''
        providers:
          # https://docs.orcarouter.ai/integrations/oh-my-pi
          orcarouter:
            baseUrl: https://api.orcarouter.ai/v1
            api: openai-completions
            apiKey: ORCAROUTER_API_KEY
            authHeader: true
            models:
              - id: orcarouter/auto
                name: OrcaRouter
                reasoning: false
                input: [text]
                contextWindow: 200000
                maxTokens: 8192
                compat:
                  supportsDeveloperRole: false
                  maxTokensField: max_tokens

          # https://tabitoken.com/pricing
          tabitoken:
            baseUrl: https://tabitoken.com/v1
            api: openai-completions
            apiKey: TABIAI_API_KEY
            models:
              - id: claude-opus-5
                name: Claude Opus 5
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-5-thinking
                name: Claude Opus 5 (Thinking)
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-4-8
                name: Claude Opus 4.8
                contextWindow: 200000
                maxTokens: 8192

              - id: claude-opus-4-8-thinking
                name: Claude Opus 4.8 (Thinking)
                contextWindow: 200000
                maxTokens: 8192

          # https://netmind.viettel.vn/codev/vi/docs/hub/installation#install-sso
          codev:
            baseUrl: https://netmind.viettel.vn/gateway/v1
            api: openai-completions
            apiKey: CODEV_API_KEY
            authHeader: true
            models:
              - id: MiniMax/MiniMax-M3
                name: MiniMax M3 (NetMind)
                contextWindow: 196608
                maxTokens: 65536

              - id: zai-org/GLM-5.3-Flash
                name: GLM 5.3 Flash (NetMind)
                contextWindow: 1048576
                maxTokens: 131072
      '';

      # NOT ".omp/agent/config.yml": omp treats that file as mutable state
      # (writes setupVersion, /model picks, wizard results) and saving through
      # an HM store symlink dies with EROFS, which re-triggers the setup wizard
      # on every launch. This file is a read-only overlay merged OVER
      # config.yml via PI_CONFIG_FILES (set in the omp alias below).
      home.file.".omp/agent/homelab.yml".text = ''
        # homelab specialization: local qwen3.8 27b as default+smol (thinking, max effort)
        modelRoles:
          default: ollama/qwen3.8:27b-qwen3-8-27b-homelab:max
          smol: ollama/qwen3.8:27b-qwen3-8-27b-homelab:low
          slow: ollama/qwen3:30b-a3b-thinking-2507-q4_K_M:high
          plan: ollama/qwen3.8:27b-qwen3-8-27b-homelab:xhigh
          advisor: ollama/qwen3:30b-a3b-thinking-2507-q4_K_M:xhigh
        defaultThinkingLevel: max
        cycleOrder:
          - smol
          - default
          - slow
        providers:
          webSearchOrder:
            - duckduckgo
            - perplexity
            - gemini
            - anthropic
            - codex
            - xai
            - zai
            - exa
            - tinyfish
            - jina
            - kagi
            - tavily
            - firecrawl
            - brave
            - kimi
            - parallel
            - synthetic
            - searxng
            - startpage
            - ecosia
            - google
            - mojeek
            - public
        symbolPreset: unicode
        theme:
          dark: titanium
          light: light
        task:
          eager: preferred
        steeringMode: one-at-a-time
        interruptMode: wait
        followUpMode: one-at-a-time
        retry:
          fallbackChains:
            plan:
              - openai-codex/gpt-5.6-luna
            slow:
              - openai-codex/gpt-5.6-luna
        composer:
          shape: box
        dev:
          autoqaConsent: granted
        browser:
          headless: true
          relay: true
      '';

      home.shellAliases = {
        omp = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path})" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path})" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path})" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path})" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path})" \
          REASONIX_SCAVENGE=1 \
          REASONIX_RESULT_CAP_TOKENS=3000 \
          PI_CONFIG_FILES="$HOME/.omp/agent/homelab.yml" \
          ${inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp}/bin/omp'';
      };
    };
  };
}
