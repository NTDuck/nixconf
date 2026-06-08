{
  flake.modules.nixos.dev-toolchains = {
    pkgs, ...
  }: {
    environment.systemPackages = [
      pkgs.unstable.deno

      pkgs.unstable.javascript-typescript-langserver
      pkgs.unstable.tailwindcss-language-server

      pkgs.unstable.svelte-language-server
    ];
  };

  flake.modules.homeManager.dev-toolchains = {
    pkgs, ...
  }: {
    programs.bun = {
      enable = true;
      package = pkgs.unstable.bun;

      settings = {
        telemetry = false;
      };
    };
  };
}