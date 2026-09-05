{den, ...}: {
  den.aspects.dev.agentics = {
    includes = [
      den.aspects.dev.agentics.harnesses

      den.aspects.dev.agentics.agent-browser
      den.aspects.dev.agentics.codegraph
      den.aspects.dev.agentics.heretic
      den.aspects.dev.agentics.huggingface
      den.aspects.dev.agentics.lmstudio
      den.aspects.dev.agentics.sesori-bridge
      den.aspects.dev.agentics.spec-kit
    ];
  };
}
