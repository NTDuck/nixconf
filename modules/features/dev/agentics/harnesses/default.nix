{den, ...}: {
  den.aspects.dev.agentics.harnesses = {
    includes = [
      den.aspects.dev.agentics.harnesses.antigravity-cli
      # claude-code + codex un-included (2026-11-11 user request):
      # aspects remain declared in their files but are not part of the
      # umbrella; re-add explicitly per host to reactivate.
      den.aspects.dev.agentics.harnesses.codev
      # disco + learnharness un-included (2026-11-10 user request):
      # aspects remain declared in their files but are not part of the
      # umbrella; re-add explicitly per host to reactivate.
      den.aspects.dev.agentics.harnesses.oh-my-pi
      den.aspects.dev.agentics.harnesses.reasonix
    ];
  };
}
