{
  pkgs,
  inputs,
  ...
}: let
  terminal-oscilloscope = pkgs.stdenv.mkDerivation {
    pname = "terminal-oscilloscope";
    version = "latest";

    src = inputs.terminal-oscilloscope;

    nativeBuildInputs = [pkgs.unstable.nim];
    buildInputs = [
      pkgs.unstable.fftw
      pkgs.unstable.portaudio
      pkgs.unstable.ncurses
      pkgs.unstable.alsa-lib
    ];

    buildPhase = ''
      nim c -d:release --opt:speed src/terminal_oscilloscope.nim
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp src/terminal_oscilloscope $out/bin/
    '';
  };
in {
  home.packages = [
    terminal-oscilloscope
  ];
}
