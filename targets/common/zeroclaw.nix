{ pkgs, ... }:

let
  zeroclaw = pkgs.rustPlatform.buildRustPackage {
    pname = "zeroclaw";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "zeroclaw-labs";
      repo = "zeroclaw";
      rev = "249434edb26de4c1345de999e568232c1da40f6b"; # <-- CHANGE THIS (use a commit hash or branch name like "main")
      hash = pkgs.lib.fakeHash;
    };

    cargoHash = pkgs.lib.fakeHash;

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    buildInputs = [
    ];
  };
in
{
  environment.systemPackages = [
    zeroclaw
  ];
}
