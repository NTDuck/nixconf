{den, ...}: {
  # romi (https://github.com/TitaniteScale/romi) — a libretro frontend and
  # game library in the terminal: runs emulator cores itself and draws the
  # game inside its own interface, with sound, saves and RetroAchievements.
  # Packaged from upstream official release binary assets (v0.5.0).
  #
  # GPU cores draw with OpenGL and need libEGL at runtime (provided by the
  # user's Mesa drivers, not bundled here); the binary itself links
  # libudev + ALSA's libasound, patched in via autoPatchelfHook.
  den.aspects.apps.gaming.romi = {
    nixos = {
      pkgs,
      lib,
      ...
    }: let
      version = "0.5.0";
      romiPkg = pkgs.stdenv.mkDerivation {
        pname = "romi";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/TitaniteScale/romi/releases/download/v${version}/romi-v${version}-x86_64-linux.tar.gz";
          hash = "sha256-CPq2mwkWjdz6m+hqsBBUuFQ3WNYF+uTVq8gJ01En9Ws=";
        };

        nativeBuildInputs = [pkgs.autoPatchelfHook];
        buildInputs = [
          pkgs.udev
          pkgs.alsa-lib
          pkgs.stdenv.cc.cc.lib
        ];

        sourceRoot = "romi-v${version}-x86_64-linux";

        installPhase = ''
          runHook preInstall
          install -Dm755 romi $out/bin/romi
          install -Dm644 README.md CREDITS.md LICENSE default-config.jsonc -t $out/share/doc/romi
          install -Dm644 completions/romi.bash $out/share/bash-completion/completions/romi
          install -Dm644 completions/romi.fish $out/share/fish/vendor_completions.d/romi.fish
          install -Dm644 completions/_romi $out/share/zsh/site-functions/_romi
          runHook postInstall
        '';

        meta = {
          description = "Play your games in your terminal: a libretro frontend and game library, with RetroAchievements";
          homepage = "https://github.com/TitaniteScale/romi";
          license = lib.licenses.mit;
          mainProgram = "romi";
          platforms = ["x86_64-linux"];
        };
      };
    in {
      environment.systemPackages = [
        romiPkg
      ];
    };
  };
}
