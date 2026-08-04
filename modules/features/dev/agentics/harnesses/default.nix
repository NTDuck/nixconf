{den, ...}: {
  den.aspects.dev.agentics.harnesses = {
    includes = [
      den.aspects.dev.agentics.harnesses.antigravity-cli
      den.aspects.dev.agentics.harnesses.claude-code
      den.aspects.dev.agentics.harnesses.codex
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.agentics.harnesses.reasonix
    ];
  };
}
