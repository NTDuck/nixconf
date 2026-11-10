{den, ...}: {
  den.aspects.dev.agentics.harnesses = {
    includes = [
      den.aspects.dev.agentics.harnesses.antigravity-cli
      den.aspects.dev.agentics.harnesses.claude-code
      den.aspects.dev.agentics.harnesses.codev
      den.aspects.dev.agentics.harnesses.codex
      # disco + learnharness un-included (2026-11-10 user request):
      # aspects remain declared in their files but are not part of the
      # umbrella; re-add explicitly per host to reactivate.
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.agentics.harnesses.reasonix
    ];
  };
}
