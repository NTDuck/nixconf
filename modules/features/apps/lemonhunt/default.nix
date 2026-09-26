{
  den,
  ...
}: {
  # Lemon Hunt: the Limoni TUI engine's raycaster game, native terminal
  # build. https://thebanri.github.io/limoni/?app=lemonhunt
  #
  # v0.9.2 predates apps/lemonhunt (404 on the tag); pinned to main HEAD
  # 29959f2 (2026-09-26). The derivation is INLINED here (not a sibling
  # package.nix): import-tree sweeps every .nix under modules/ as a
  # module, and the module system would feed the package flake args.
  den.aspects.apps.lemonhunt = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: let
      lemonhunt = pkgs.buildGoModule {
        pname = "lemonhunt";
        version = "0.9.2-unstable-2026-09-26";

        src = pkgs.fetchFromGitHub {
          owner = "thebanri";
          repo = "limoni";
          rev = "29959f28b2f47a6e8be564ef70a5be8daad3fb36";
          hash = "sha256-WmNHmxIgCZHP0mPYI1JqNl40/NnxeMKvvnJyhfbbCeY=";
        };

        # apps/lemonhunt is a separate Go module nested inside the limoni
        # repo (own go.mod pinning github.com/thebanri/limoni v0.9.2 as
        # the engine).
        modRoot = "apps/lemonhunt";

        vendorHash = "sha256-1jbjdZ9pat1NHtly1wu/LQmKhwWxyp5F2ckOdGtSjhg=";

        env.CGO_ENABLED = "0";

        meta = {
          description = "Raycaster game for the Limoni TUI engine (native terminal build)";
          homepage = "https://thebanri.github.io/limoni/?app=lemonhunt";
          license = lib.licenses.asl20;
          mainProgram = "lemonhunt";
        };
      };
    in {
      home.packages = [lemonhunt];
    };
  };
}
