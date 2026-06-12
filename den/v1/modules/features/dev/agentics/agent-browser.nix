{ den, inputs, ... }: {
  den.aspects.agentBrowser = {
    nixos = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.unstable.agent-browser
      ];
    };
  };
}
