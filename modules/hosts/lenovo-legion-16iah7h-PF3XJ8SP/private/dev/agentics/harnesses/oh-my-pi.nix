{den, ...}: {
  den.aspects.lenovo-legion-16iah7h-PF3XJ8SP = {
    # homeManager = {
    #   config,
    #   pkgs,
    #   ...
    # }: let
    #   # Concrete OMP selectors for models discovered from the local Ollama server.
    #   localModels = {
    #     base = "ollama/qwen3.5:4b-q4_K_M";

    #     fast =
    #       "ollama/hf.co/unsloth/"
    #       + "Qwen3-4B-Instruct-2507-GGUF:UD-Q4_K_XL";

    #     quality =
    #       "ollama/hf.co/unsloth/"
    #       + "Qwen3-4B-Instruct-2507-GGUF:Q5_K_M";
    #   };

    #   yaml = pkgs.formats.yaml {};

    #   # Use an immutable overlay rather than replacing ~/.omp/agent/config.yml.
    #   #
    #   # This preserves OMP's writable user configuration and OAuth/API-key
    #   # database while enforcing host-specific local-subagent routing.
    #   localSubagentConfig = yaml.generate "omp-local-subagents.yml" {
    #     modelRoles = {
    #       # default = ...;
    #     };

    #     task = {
    #       # The laptop GPU should execute one local worker at a time. This avoids
    #       # concurrent model loading and excessive KV-cache/VRAM pressure.
    #       maxConcurrency = 1;

    #       # Child workers must not recursively spawn more workers.
    #       maxRecursionDepth = 1;

    #       # These exact mappings have higher precedence than bundled-agent
    #       # frontmatter and than the active cloud parent model.
    #       agentModelOverrides = {
    #         # Fast, read-oriented repository discovery.
    #         scout = localModels.base;
    #         librarian = localModels.base;

    #         # Fast bounded worker.
    #         sonic = localModels.fast;

    #         # Higher-quality implementation, review, and architecture workers.
    #         task = localModels.quality;
    #         reviewer = localModels.quality;
    #         designer = localModels.quality;
    #       };
    #     };
    #   };
    # in {
    #   home.sessionVariables = {
    #     # OMP discovers Ollama automatically, but setting this explicitly makes
    #     # the host routing independent of future defaults.
    #     OLLAMA_BASE_URL = "http://${config.services.ollama.host}:${builtins.toString config.services.ollama.port}";

    #     # Loaded after normal global/project settings. It does not replace
    #     # ~/.omp/agent/config.yml and does not interfere with agent.db.
    #     PI_CONFIG_FILES = "${localSubagentConfig}";
    #   };

    #   # Preserve OMP's built-in prompt, tool instructions, skills, and context.
    #   # This file only adds a host-wide orchestration policy.
    #   # home.file.".omp/agent/APPEND_SYSTEM.md".text = ''
    #   #   # Default local-subagent policy

    #   #   You are the parent and orchestrator. Keep the currently selected model as
    #   #   the parent model, whether it is DeepSeek, Gemini, Anthropic, OpenAI, or
    #   #   another authenticated provider.

    #   #   ## Required delegation behavior

    #   #   When the `task` tool is available, use at least one local subagent before
    #   #   answering every non-trivial request involving any of the following:

    #   #   - repository or source-code inspection;
    #   #   - debugging or root-cause analysis;
    #   #   - implementation or refactoring;
    #   #   - architecture or implementation planning;
    #   #   - technical research requiring multiple sources;
    #   #   - code, configuration, or security review;
    #   #   - validation of a material proposed change.

    #   #   Do not delegate greetings, trivial factual questions, simple text
    #   #   transformations, or requests that clearly require no investigation.

    #   #   ## Agent selection

    #   #   - Use `scout` for repository reconnaissance, locating files, call paths,
    #   #     definitions, and existing conventions.
    #   #   - Use `librarian` for documentation, external-source, and reference
    #   #     investigation.
    #   #   - Use `sonic` for small, bounded, low-risk analysis.
    #   #   - Use `task` for implementation and substantial technical work.
    #   #   - Use `reviewer` after a material implementation or configuration change.
    #   #   - Use `designer` for architecture, interfaces, and system design.

    #   #   Prefer a sequence such as:

    #   #   1. `scout` or `librarian` gathers evidence.
    #   #   2. The parent synthesizes a plan.
    #   #   3. `task` performs implementation when modification is requested.
    #   #   4. `reviewer` validates material changes.
    #   #   5. The parent checks the returned claims against source and tool output.

    #   #   Run local workers synchronously and one at a time unless the user
    #   #   explicitly requests parallel execution. Do not duplicate work that a
    #   #   completed worker has already performed.

    #   #   ## Child-session behavior

    #   #   If the `task` tool is unavailable, this session is probably already a
    #   #   spawned subagent. Perform the assigned task directly and return a concise,
    #   #   evidence-based result. Do not attempt further delegation.

    #   #   ## Security

    #   #   Never send API keys, OAuth tokens, passwords, private credentials, or
    #   #   unredacted secret files to a subagent. Pass only the minimum sanitized
    #   #   context needed for the delegated task.

    #   #   The parent remains responsible for correctness. Treat subagent output as
    #   #   evidence, not as automatically verified truth.
    #   # '';
    # };
  };
}
