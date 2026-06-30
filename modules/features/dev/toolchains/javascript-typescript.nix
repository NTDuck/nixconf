{den, ...}: {
  den.aspects.dev.toolchains.javascript-typescript = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      nixpkgs.config.allowInsecurePredicate = pkg:
        pkg
        |> lib.getName
        |> (name: builtins.elem name ["pnpm"]);

      environment.systemPackages = [
        pkgs.unstable.nodejs
        pkgs.unstable.deno

        pkgs.unstable.javascript-typescript-langserver
        pkgs.unstable.tailwindcss-language-server

        pkgs.unstable.svelte-language-server
      ];
    };

    homeManager = {pkgs, ...}: {
      programs.bun = {
        enable = true;
        package = pkgs.unstable.bun;

        settings = {
          telemetry = false;
        };
      };
    };
  };
}
