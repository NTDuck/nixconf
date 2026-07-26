{den, ...}: {
  den.aspects.dev.agentics.harnesses.codex = {
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      programs.codex = {
        enable = true;
        package = pkgs.unstable.codex;
      };

      home.shellAliases = {
        codex = "${config.programs.codex.package}/bin/codex --dangerously-bypass-approvals-and-sandbox";
      };
    };
  };
}
