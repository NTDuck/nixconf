{ pkgs, ... }:

let
  zeroclaw = pkgs.rustPlatform.buildRustPackage {
    pname = "zeroclaw";
    version = "latest";

    src = pkgs.fetchFromGitHub {
      owner = "zeroclaw-labs";
      repo = "zeroclaw";
      rev = "249434edb26de4c1345de999e568232c1da40f6b";
      hash = "sha256-dSRVYrVm24LVmIaiJpAiQ3HaHm9Vr9jLSMPKCCrlneY="; # pkgs.lib.fakeHash
    };

    cargoHash = "sha256-2DLiGeeLMa8nhR7Gtw5SPzd/2cddHv+CHHtQKSBWOoY="; # pkgs.lib.fakeHash;

    nativeBuildInputs = [
      pkgs.pkg-config
    ];

    doCheck = false;
  };
in
{
  environment.systemPackages = [
    zeroclaw
  ];
}
