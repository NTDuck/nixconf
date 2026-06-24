{den, ...}: {
  den.aspects.dev.agentics = {
    includes = [
      den.aspects.dev.agentics.agent-browser
      den.aspects.dev.agentics.antigravity-cli
      den.aspects.dev.agentics.claude-code
      den.aspects.dev.agentics.codex
      den.aspects.dev.agentics.ollama
      den.aspects.dev.agentics.qoder-cli
      den.aspects.dev.agentics.spec-kit
    ];
  };
}
