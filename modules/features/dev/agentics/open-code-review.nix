{
  den,
  inputs,
  ...
}: {
  # 2026-10-21: Alibaba's open-code-review (ocr) CLI provides AI-powered
  # line-level code reviews on Git diffs. Installed declaratively via
  # llm-agents.nix, which publishes prebuilt cached binaries on cache.numtide.com.
  den.aspects.dev.agentics.open-code-review = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.open-code-review
      ];
    };
  };
}
