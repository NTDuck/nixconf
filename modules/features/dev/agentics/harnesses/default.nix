{den, ...}: {
  den.aspects.dev.agentics = {
    includes = [
      den.aspects.dev.agentics.antigravity-cli
      den.aspects.dev.agentics.claude-code
      den.aspects.dev.agentics.codex
      den.aspects.dev.agentics.goose-cli
      den.aspects.dev.agentics.spec-kit
    ];
  };

  den.aspects.dev.agentics.local-inference = {};
}
