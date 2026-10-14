{den, ...}: {
  # ctx7: Context7 CLI - manage AI coding skills and documentation context (context7.com).
  den.aspects.dev.agentics.ctx7 = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.ctx7
      ];
    };
  };
}
