# Legion omp client: models.yml + the `omp` alias (host-private).
#
# SHAPE HISTORY (2026-09-27): 4e3be54 (2026-09-26 18:37, user-directed
# revert) restored this file verbatim to a pre-fb75273 LITERAL models.yml
# — which dropped the homelab local provider blocks that fb75273 (same
# day, 12:52) had added and live-verified. models.yml REPLACES omp's
# implicit catalog, so without a local provider entry /model lists NO
# local models at all on the homelab spec. Fix: local blocks restored as
# a spec-gated attrset (the literal .text shape cannot express the
# specialisation gate); the 4e3be54 alias (5-secret export) and cloud
# providers are kept verbatim.
#
# 2026-10-12: ollama removed entirely (user request — ninfer is the
# sole local engine). The local attrset now only carries ninfer.
{
  den,
  inputs,
  ...
}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    homeManager = {
      lib,
      osConfig,
      pkgs,
      ...
    }: let
      yaml = pkgs.formats.yaml {};

      # omp release binary (2026-11-09): upstream omp-linux-x64, hash-
      # pinned in _omp-release.nix, interpreter-only patchelf to the
      # store glibc (autoPatchelfHook corrupts the bun-embedded bundle —
      # see _omp-release.nix header). Replaces the patched llm-agents
      # source build (vibe patch cancelled 2026-11-09, so no source
      # build is needed anywhere anymore).
      ompBinPath =
        import "${inputs.self}/modules/features/dev/agentics/harnesses/omp/_release.nix" {inherit pkgs lib;};

      # Port the ninfer-serve listens on. Single source of
      # truth for this host; remote hosts (dell) duplicate the value
      # with a sync comment in their models.yml. The den module system
      # does NOT support top-level `options` (it wraps values in aspect
      # objects, so `den.aspects.X.port` returns an aspect object, not
      # the raw value), so the port is duplicated here as a let-binding
      # and referenced via `toString ninferPort` in the provider block.
      # MUST match `ninferPort` in ../ninfer/default.nix.
      ninferPort = 8092;
      # 3090 gating (2026-09-21, 3090 specialisation pattern): the local
      # ninfer provider exists ONLY inside the homelab
      # specialisation — the daemon it points at is gated there too
      # (../ninfer/default.nix). osConfig.isSpecialisation is mkOverride-0
      # true inside spec evals (nixos/modules/system/activation/
      # no-clone.nix) and false in the default generation, so the two
      # models.yml variants diverge on this flag and there is no module
      # collision (the spec HM eval replaces the default HM config
      # wholesale).
      onHomelabSpec = osConfig.isSpecialisation or false;

      cloudProviders = {
        # https://docs.orcarouter.ai/integrations/oh-my-pi
        # (2026-09-27 note: orcarouter-api-key.age still decrypts to 0
        # bytes — key lost 2026-09-26. Kept per the 4e3be54 user-directed
        # revert; calls 401 until a fresh key is fed via `agenix -e`.)
        orcarouter = {
          baseUrl = "https://api.orcarouter.ai/v1";
          api = "openai-completions";
          apiKey = "ORCAROUTER_API_KEY";
          authHeader = true;

          models = [
            {
              id = "orcarouter/auto";
              name = "OrcaRouter";
              reasoning = false;
              input = ["text"];
              contextWindow = 200000;
              maxTokens = 8192;

              compat = {
                supportsDeveloperRole = false;
                maxTokensField = "max_tokens";
              };
            }
          ];
        };

        # https://tabitoken.com/pricing
        tabitoken = {
          baseUrl = "https://tabitoken.com/v1";
          api = "openai-completions";
          apiKey = "TABIAI_API_KEY";

          models = [
            {
              id = "claude-opus-5";
              name = "Claude Opus 5";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-5-thinking";
              name = "Claude Opus 5 (Thinking)";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-4-8";
              name = "Claude Opus 4.8";
              contextWindow = 200000;
              maxTokens = 8192;
            }

            {
              id = "claude-opus-4-8-thinking";
              name = "Claude Opus 4.8 (Thinking)";
              contextWindow = 200000;
              maxTokens = 8192;
            }
          ];
        };

        # https://netmind.viettel.vn/codev/vi/docs/hub/installation#install-sso
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

            # Gateway-reported id (curl /v1/models 2026-09-26); the gateway
            # omits max_input_tokens/max_output_tokens for this entry, so
            # pin to the same conservative window as MiniMax/MiniMax-M3
            # (gateway reports 1M/128K for that one but trims in practice).
            {
              id = "zai-org/GLM-5.3-Flash";
              name = "GLM 5.3 Flash (NetMind)";
              reasoning = true;
              contextWindow = 196608;
              maxTokens = 65536;
            }
          ];
        };
      };

      # 3090-coupled local providers — homelab spec only (see
      # onHomelabSpec). Restored verbatim from fb75273 (2026-09-26), the
      # last live-verified state. 2026-10-12: ollama removed; ninfer
      # is the sole local engine. 2026-11-11: ids/names synced with the
      # `ninfer list` contract (bonsai2 -> bonsai2-27b, alphabetical).
      # coder390 dropped — its artifact FATALs on engine 0.17.2
      # (gguf_blocks_v1 tensors, see ninfer/default.nix CODER390
      # REJECTED).
      local = {
        # Consolidated ninfer engine (port 8092, resident 3090 engine).
        # Single provider hosting all 4 canonical model variants.
        # Mutual conflicts ensure one daemon runs at a time on :8092,
        # switched on-demand via `ninfer switch <model-id> [C]x<ctx>`.
        ninfer = {
          baseUrl = "http://127.0.0.1:${toString ninferPort}/v1";
          api = "openai-completions";
          auth = "none";

          models = [
            {
              id = "bonsai2-27b";
              name = "Ternary Bonsai 2 27B";
              reasoning = true;
              input = ["text" "image"];
              contextWindow = 262144;
              maxTokens = 65536;
            }
            {
              id = "bonsai2-27b-abliterated";
              name = "Ternary Bonsai 2 27B Abliterated (Heretic)";
              reasoning = true;
              input = ["text" "image"];
              contextWindow = 262144;
              maxTokens = 65536;
            }
            {
              id = "qwen3.8-27b";
              name = "Qwen 3.8 27B DFlash2";
              reasoning = true;
              input = ["text" "image"];
              contextWindow = 65536;
              maxTokens = 16384;
            }
            {
              id = "qwen3.8-27b-turbo";
              name = "Qwen 3.8 27B Turbo (Heretic)";
              reasoning = true;
              input = ["text" "image"];
              contextWindow = 262144;
              maxTokens = 65536;
            }
          ];
        };
      };

      # Web-LLM tunnel (2026-11-10): local Gemini web gateway exposed as
      # an OpenAI-compatible provider so omp agents can route advice
      # turns to free web LLMs. Key is read at alias launch (env-var
      # interpolation) — see the omp alias secret block.
      #
      #   gw2a — gemini-web2api-go (podman, 127.0.0.1:8083): Gemini web
      #          UI → /v1/chat/completions. Key auto-generated at first
      #          container boot, rotatable in the admin dashboard
      #          (http://127.0.0.1:8083/admin). Cookie optional (adds
      #          gemini-3.1-pro/3.8-flash/4-argon + image/music/video).
      #
      # CLIProxyAPI (127.0.0.1:8317) is deliberately NOT listed here:
      # its model ids are DYNAMIC per logged-in OAuth account (tier-
      # suffixed, e.g. gemini-3.5-flash-low) and would 404 if hardcoded.
      # Agents use the `ask-web-llm` skill, which probes /v1/models.
      webTunnelProviders = {
        gw2a = {
          baseUrl = "http://127.0.0.1:8083/v1";
          api = "openai-completions";
          apiKey = "GEMINI_WEB2API_KEY";
          authHeader = true;

          models = [
            {
              id = "gemini-3.6-flash";
              name = "Gemini 3.6 Flash (Web)";
              contextWindow = 256000;
              maxTokens = 65536;
            }
            {
              id = "gemini-3.5-flash-lite";
              name = "Gemini 3.5 Flash Lite (Web)";
              contextWindow = 256000;
              maxTokens = 65536;
            }
            {
              id = "gemini-3.1-pro";
              name = "Gemini 3.1 Pro (Web, cookie)";
              reasoning = true;
              contextWindow = 256000;
              maxTokens = 65536;
            }
            {
              id = "gemini-3.8-flash";
              name = "Gemini 3.8 Flash (Web, paid cookie)";
              contextWindow = 256000;
              maxTokens = 65536;
            }
          ];
        };
      };
      # Caps Gemini models from default 1M to 256k contextWindow across all active
      # Gemini-bearing providers (2026-10-18 user request).
      geminiOverrides = import "${inputs.self}/modules/features/dev/agentics/harnesses/omp/_gemini-overrides.nix";

      models = {
        providers =
          lib.recursiveUpdate (
            cloudProviders
            // webTunnelProviders
            // (
              if onHomelabSpec
              then local
              else {}
            )
          )
          geminiOverrides;
      };

      # `ompl` = a Qwen3.8-27B-ONLY harness: every chat role pinned to
      # the local ninfer engine (../ninfer/default.nix), running
      # under a dedicated `--profile ompl` agent dir
      # (~/.omp/profiles/ompl/agent). The profile isolates ALL agent
      # state — sessions, history.db, agent.db, models.db, stored auth,
      # memories, blobs, terminal-sessions — from the default
      # ~/.omp/agent dir ("no memory or persistence" user requirement,
      # 2026-10-11): nothing ompl does lands in omp's shared store, and
      # the fresh profile starts with NO stored cloud credentials.
      #
      # models.yml resolves from the ACTIVE agent dir, so the profile
      # needs its own qwen-only models.yml (omplModels below) — the
      # shared ~/.omp/agent/models.yml (cloud + ninfer) is NOT
      # visible to it. Without a profile-local file the ninfer
      # selector is unresolvable and the harness SILENTLY degrades to a
      # cloud model: reproduced 2026-10-11, a profile launch with no
      # models.yml routed to openrouter and died 402 "requires more
      # credits" while the status line still said Qwen. The qwen-only
      # file is the first gate; the overlay keys below are the rest.
      #
      # qwen-only gates (defense in depth — the fresh auth store alone
      # cannot cover env-var keys such as OPENROUTER_API_KEY inherited
      # from a shell that previously ran `omp`):
      #   enabledModels     — chat selection (startup model, /model
      #                       picker, Ctrl+P cycling) scoped to the one
      #                       model.
      #   disabledProviders — removes backends from selection even when
      #                       credentials exist. Covers the env-var-
      #                       backed cloud ids observed on this host
      #                       plus the implicit KEYLESS local probes
      #                       (llama.cpp/lm-studio are keyless, hence
      #                       available with zero credentials — this
      #                       replaces config.default.yml's [llama.cpp]
      #                       entry; arrays replace, not append).
      #   retry.modelFallback — false: a pinned role whose engine is
      #                       down must FAIL LOUDLY,
      #                       never leak a turn to a cloud model (no
      #                       fallbackChains by design — same intent).
      #
      # no-memory keys (overlay beats config.default.yml's mnemopi
      # backend and the enabled autolearn nudge):
      #   memory.backend: off — no Mnemopi long-term memory
      #   autolearn.enabled: false — no post-stop lesson/skill capture
      #
      # Non-chat roles (image/speech/dictation/web, tiny, memory) are
      # deliberately absent: no local engine serves those kinds, and
      # pinning them to qwen3.8-27b would just 404 or hallucinate
      # capabilities. `judge` accepts chat models, so it is pinned;
      # `commit`/`task` are ordinary chat roles (auto-resolve from
      # default when unset, but pinned for determinism). `:high` is
      # this model's top effort — the catalog has no `max` for it
      # (minimal/low/medium/high only; verified against `omp models`
      # + engine logs 2026-10-11).
      omplOverlay = {
        modelRoles = {
          default = "ninfer/qwen3.8-27b-turbo:high";
          smol = "ninfer/qwen3.8-27b-turbo:high";
          slow = "ninfer/qwen3.8-27b-turbo:high";
          vision = "ninfer/qwen3.8-27b-turbo:high";
          plan = "ninfer/qwen3.8-27b-turbo:high";
          commit = "ninfer/qwen3.8-27b-turbo:high";
          task = "ninfer/qwen3.8-27b-turbo:high";
          advisor = "ninfer/qwen3.8-27b-turbo:high";
          judge = "ninfer/qwen3.8-27b-turbo:high";
        };

        enabledModels = [
          "ninfer/bonsai2-27b"
          "ninfer/bonsai2-27b-abliterated"
          "ninfer/qwen3.8-27b"
          "ninfer/qwen3.8-27b-turbo"
        ];
        disabledProviders = [
          # implicit keyless local probes
          "llama.cpp"
          "lm-studio"
          "apple"
          # env-var/stored-credential cloud ids observed on this host
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

        # vibe-by-default (2026-10-22, user request "make ompl vibe on by
        # default"): REVERTED 2026-11-09 — the vibe.defaultOnStartup key
        # required a local source patch (patches/omp-vibe-default-on-
        # startup.patch) that blocked switching omp to the upstream
        # release binary. The patch is gone; start vibe with /vibe or the
        # TUI toggle. Unknown settings keys pass through harmlessly, but
        # the key no longer does anything, so it is removed entirely.
      };

      # Profile-local qwen-only models.yml. Reuses local.ninfer
      # (single source of the provider block). On the default
      # generation the ninfer port is simply down and ompl fails
      # loudly — as designed, same as service gating the
      # shared provider.
      omplModels = {
        providers = {
          ninfer = local.ninfer;
        };
      };

      # `omprp` = roleplaying harness (2026-11-01): runs under `--profile omprp`
      # (~/.omp/profiles/omprp/agent) wired to the active ninfer model.
      # Unlike ompl (stateless coding scratchpad), omprp is tuned for
      # roleplay and creative prose:
      #   hideThinkingBlock: true      - suppress reasoning/thinking logs in output
      #   memory.backend: mnemopi      - persistent SQLite memory across sessions
      #   autolearn.enabled: true      - persist learnings and memories
      #   advisor.enabled: false       - advisor runtime disabled (no passive turns/notes)
      #   personality: "none"          - omit engineering personality constraints
      #   git.enabled: false           - suppress git branch/status checks and UI indicators
      omprpOverlay = {
        modelRoles = {
          default = "ninfer/qwen3.8-27b-turbo:high";
          smol = "ninfer/qwen3.8-27b-turbo:high";
          slow = "ninfer/qwen3.8-27b-turbo:high";
          vision = "ninfer/qwen3.8-27b-turbo:high";
          plan = "ninfer/qwen3.8-27b-turbo:high";
          commit = "ninfer/qwen3.8-27b-turbo:high";
          task = "ninfer/qwen3.8-27b-turbo:high";
          advisor = "ninfer/qwen3.8-27b-turbo:high";
          judge = "ninfer/qwen3.8-27b-turbo:high";
        };

        enabledModels = [
          "ninfer/bonsai2-27b"
          "ninfer/bonsai2-27b-abliterated"
          "ninfer/qwen3.8-27b"
          "ninfer/qwen3.8-27b-turbo"
        ];
        disabledProviders = [
          # implicit keyless local probes
          "llama.cpp"
          "lm-studio"
          "apple"
          # env-var/stored-credential cloud ids observed on this host
          "litellm"
          "openrouter"
          "opencode-go"
          "opencode-zen"
          "google-antigravity"
          "openai-codex"
        ];

        retry.modelFallback = false;

        hideThinkingBlock = true;
        memory.backend = "mnemopi";
        autolearn.enabled = true;

        advisor.enabled = false;
        personality = "none";
        git.enabled = false;
      };

      omprpModels = omplModels;

      # A named profile's agent dir resolves ITS OWN extensions/ and
      # keybindings.yml — the shared aspect's copies in ~/.omp/agent/
      # are invisible to it (verified 2026-10-11: no "[pi-reasonix]
      # Loaded" line under --profile with an empty profile dir). So the
      # profile gets its own: pi-reasonix (cache-first prefix work, cost
      # metrics) and the ctrl+v pasteImage remap (app.clipboard.pasteImage
      # -> alt+v, 2026-09-25 user bug: image chip instead of paste).
      #
      # Re-derived here rather than plucked from osConfig's
      # environment.systemPackages: the homeManager aspect's osConfig
      # does not carry systemPackages (findFirst returned null — build
      # error 2026-10-11). Same fetchurl+hash as the shared aspect
      # (oh-my-pi.nix:24-53), so content cannot diverge; keep the
      # version in sync.
      reasonixPkg = pkgs.stdenv.mkDerivation rec {
        pname = "pi-reasonix";
        version = "1.1.0";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/pi-reasonix/-/pi-reasonix-${version}.tgz";
          hash = "sha512-pK9ig80y8l8shFoWGJx+ylg+dQ2qj9a/3z+nIkCDcsCW+3TsbqyeNrm0B/Pb4YcaczUjDBnVJHtByzbh+JJVzQ==";
        };

        dontBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/pi-reasonix
          cp -r * $out/lib/node_modules/pi-reasonix/
          mkdir -p $out/share/omp/extensions
          ln -s $out/lib/node_modules/pi-reasonix/dist/extensions/index.js $out/share/omp/extensions/pi-reasonix.js
          runHook postInstall
        '';

        meta = {
          description = "DeepSeek-native optimizations for Pi / Oh-My-Pi: cache-first prefix stabilization, tool-call repair, and cost control";
          homepage = "https://github.com/TheTrebor/pi-reasonix";
          license = pkgs.lib.licenses.mit;
        };
      };

      # pi-antigravity (2026-10-20): Antigravity / Cloud Code Assist
      # provider extension — wire-format parity for gemini-3.8-flash
      # "Request was aborted" watchdog loops (user guideline request).
      # Ships TS SOURCE ONLY (package.json main = ./src/index.ts, no
      # dist, no build script): omp 18.12.3 loads .ts extension entries
      # directly (Bun transpiles; probe-verified against this exact
      # layout, including the .js-named symlink), so no tsc build —
      # just materialize the package + its ONE runtime dep. Runtime
      # deps: undici 8.11.2 (zero transitive deps), copied flat into a
      # package-root node_modules. The @earendil-works/* peers are
      # omp-provided: the loader rewrites those specifiers onto its
      # bundled pi-ai/pi-coding-agent APIs (probe-verified: the full
      # antigravity.{doctor,models,accounts,refresh,search,usage,image}
      # command set registers with exactly this layout). Plugin's own
      # stream watchdogs (ANTIGRAVITY_STREAM_{HEADER,STALL}_TIMEOUT_MS)
      # default to 180s/120s — no env needed; the abort was omp's
      # generic first-event watchdog, fixed via PI_STREAM_* in the
      # shared aspect.
      antigravityPkg = pkgs.stdenv.mkDerivation rec {
        pname = "pi-antigravity";
        version = "0.11.0";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/pi-antigravity/-/pi-antigravity-${version}.tgz";
          hash = "sha512-oCiwNp6yQ8B1hPbQTqdTUsKJOiG7o5RSJmqLsS3wgYXg9y+2goL/TjaF0xZHLgN/S7zSBv7hX3ksnug1fNhabw==";
        };

        undiciSrc = pkgs.fetchurl {
          url = "https://registry.npmjs.org/undici/-/undici-8.11.2.tgz";
          hash = "sha512-u4UB2/IrKdU6lFxumHmmo1a3fCQO5tzQllRorfoRS63txhrB7xTpSn1PftwC4qEHkOaqP95fCWW4lJzwErwzhQ==";
        };

        dontBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/pi-antigravity/node_modules
          cp -r . $out/lib/node_modules/pi-antigravity/
          # npm tarballs unpack under a package/ prefix (no strip):
          # rename to the module id undici resolves from.
          tar xzf ${undiciSrc} -C $out/lib/node_modules/pi-antigravity/node_modules
          mv $out/lib/node_modules/pi-antigravity/node_modules/package \
            $out/lib/node_modules/pi-antigravity/node_modules/undici
          mkdir -p $out/share/omp/extensions
          # Entry is TS; omp discovers and transpiles it regardless of
          # the .js name (probe-verified both spellings).
          ln -s $out/lib/node_modules/pi-antigravity/src/index.ts $out/share/omp/extensions/pi-antigravity.js
          runHook postInstall
        '';

        meta = {
          description = "Personal Antigravity / Cloud Code Assist provider for Pi Coding Agent";
          homepage = "https://github.com/Rahularya01/pi-antigravity";
          license = pkgs.lib.licenses.mit;
        };
      };
      # ompl wrapper (2026-10-30): dynamically queries active model via ninfer active,
      # generates a runtime overlay in $XDG_RUNTIME_DIR/omp/ompl-active.yml,
      # and sets modelRoles to the active model instead of hardcoding qwen3.8-27b-turbo.
      omplWrapper = pkgs.writeShellScriptBin "ompl" ''
                set -euo pipefail

                active_model="$( ${pkgs.curl}/bin/curl -s -m 0.5 http://127.0.0.1:${toString ninferPort}/v1/models 2>/dev/null | ${pkgs.jq}/bin/jq -r '.data[0].id // empty' 2>/dev/null || true )"
                if [ -z "$active_model" ]; then
                  active_model="$( ninfer active 2>/dev/null || true )"
                fi
                active_model="''${active_model:-qwen3.8-27b-turbo}"

                runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/omp"
                mkdir -p "$runtime_dir"
                active_overlay="$runtime_dir/ompl-active.yml"

                cat << EOF > "$active_overlay"
        modelRoles:
          default: ninfer/$active_model:high
          smol: ninfer/$active_model:high
          slow: ninfer/$active_model:high
          vision: ninfer/$active_model:high
          plan: ninfer/$active_model:high
          commit: ninfer/$active_model:high
          task: ninfer/$active_model:high
          advisor: ninfer/$active_model:high
          judge: ninfer/$active_model:high
        EOF

                export PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/ompl.yml:$active_overlay"
                exec "${ompBinPath}/bin/omp" --profile ompl "$@"
      '';

      # omprp wrapper (2026-11-01): dynamically queries active model via ninfer active,
      # generates a runtime overlay in $XDG_RUNTIME_DIR/omp/omprp-active.yml,
      # and sets modelRoles to the active model, optimized for roleplay.
      omprpWrapper = pkgs.writeShellScriptBin "omprp" ''
                set -euo pipefail

                active_model="$( ${pkgs.curl}/bin/curl -s -m 0.5 http://127.0.0.1:${toString ninferPort}/v1/models 2>/dev/null | ${pkgs.jq}/bin/jq -r '.data[0].id // empty' 2>/dev/null || true )"
                if [ -z "$active_model" ]; then
                  active_model="$( ninfer active 2>/dev/null || true )"
                fi
                active_model="''${active_model:-qwen3.8-27b-turbo}"

                runtime_dir="''${XDG_RUNTIME_DIR:-/tmp}/omp"
                mkdir -p "$runtime_dir"
                active_overlay="$runtime_dir/omprp-active.yml"

                cat << EOF > "$active_overlay"
        modelRoles:
          default: ninfer/$active_model:high
          smol: ninfer/$active_model:high
          slow: ninfer/$active_model:high
          vision: ninfer/$active_model:high
          plan: ninfer/$active_model:high
          commit: ninfer/$active_model:high
          task: ninfer/$active_model:high
          advisor: ninfer/$active_model:high
          judge: ninfer/$active_model:high
        EOF

                export PI_CONFIG_FILES="$HOME/.omp/agent/config.default.yml:$HOME/.omp/agent/omprp.yml:$active_overlay"
                exec "${ompBinPath}/bin/omp" --profile omprp "$@"
      '';
    in {
      # force = true (2026-10-18): self-heal over pre-existing unmanaged or
      # test-linked models.yml/ompl.yml so HM activation checkLinkTargets does not fail.
      home.file.".omp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.models.yml" models;
        force = true;
      };

      # PI_CONFIG_FILES overlay (merged OVER config.yml/config.default.yml;
      # later overlays win), see the omplOverlay comment above.
      home.file.".omp/agent/ompl.yml" = {
        source = yaml.generate ".omp.agent.ompl.yml" omplOverlay;
        force = true;
      };
      home.file.".omp/agent/omprp.yml" = {
        source = yaml.generate ".omp.agent.omprp.yml" omprpOverlay;
        force = true;
      };

      # --- omprp profile support files (~/.omp/profiles/omprp/agent/) ---
      home.file.".omp/profiles/omprp/agent/models.yml" = {
        source = yaml.generate ".omp.agent.omprp-models.yml" omprpModels;
        force = true;
      };
      home.file.".omp/profiles/omprp/agent/keybindings.yml".text = ''
        keybindings:
          app.clipboard.pasteImage: "alt+v"
      '';

      home.file.".omp/profiles/omprp/agent/extensions/pi-reasonix.js".source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";

      # --- ompl profile support files (~/.omp/profiles/ompl/agent/) ---
      home.file.".omp/profiles/ompl/agent/models.yml" = {
        source = yaml.generate ".omp.agent.ompl-models.yml" omplModels;
        force = true;
      };
      home.file.".omp/profiles/ompl/agent/keybindings.yml".text = ''
        keybindings:
          app.clipboard.pasteImage: "alt+v"
      '';

      home.file.".omp/profiles/ompl/agent/extensions/pi-reasonix.js".source = "${reasonixPkg}/share/omp/extensions/pi-reasonix.js";

      # Extension entry for the DEFAULT agent dir (~/.omp/agent/
      # extensions/) — ompl stays qwen-only by design; this is the
      # gemini-3.8-flash wire-format fix, so it must NOT land in the
      # ompl profile (its disabledProviders also already excludes the
      # google-antigravity cloud provider).
      home.file.".omp/agent/extensions/pi-antigravity.js".source = "${antigravityPkg}/share/omp/extensions/pi-antigravity.js";

      home.packages = [
        omplWrapper
        omprpWrapper
      ];
      # Ensure cargo bin path does not shadow the dynamic wrapper with a stale script
      home.file.".cargo/bin/ompl" = {
        source = "${omplWrapper}/bin/ompl";
        force = true;
      };
      home.file.".cargo/bin/omprp" = {
        source = "${omprpWrapper}/bin/omprp";
        force = true;
      };

      home.shellAliases = {
        omp = ''
          CODEV_API_KEY="$(cat ${osConfig.age.secrets."codev-api-key".path} 2>/dev/null || cat ~/.codev/auth.json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.api_key // empty')" \
          ORCAROUTER_API_KEY="$(cat ${osConfig.age.secrets."orcarouter-api-key".path} 2>/dev/null)" \
          OPENCODE_API_KEY="$(cat ${osConfig.age.secrets."opencode-api-key".path} 2>/dev/null)" \
          OPENROUTER_API_KEY="$(cat ${osConfig.age.secrets."openrouter-api-key".path} 2>/dev/null)" \
          TABIAI_API_KEY="$(cat ${osConfig.age.secrets."tabiai-api-key".path} 2>/dev/null)" \
          GEMINI_WEB2API_KEY="$(cat ''${XDG_CONFIG_HOME:-$HOME/.config}/webllm/gemini-web2api-key 2>/dev/null)" \
          CLIPROXY_API_KEY="$(cat /var/lib/cli-proxy-api/api-key 2>/dev/null)" \
          ${ompBinPath}/bin/omp'';

        # Same omp binary plus `--profile ompl`: isolated agent dir
        # (see the omplOverlay comment — no shared sessions/history/
        # auth, i.e. no persistence) and the qwen-only overlay. NO
        # secret exports: auth is none (local engine) and no cloud
        # provider is reachable, so there is nothing to authenticate.
        # Kept as a separate alias (the shared aspect owns `omp` via
        # mkDefault; the 5-secret export block above is duplicated by
        # design for `omp` — see its comment).
        #
        # 2026-11-09: all aliases now run the upstream release binary
        # (ompBinPath, _omp-release.nix). The former ompVibePkg source
        # patch (vibe.defaultOnStartup) was cancelled — see the
        # omplOverlay comment.
        ompl = "${omplWrapper}/bin/ompl";
        omprp = "${omprpWrapper}/bin/omprp";
      };
    };
  };
}
