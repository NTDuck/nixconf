{
  pkgs,
  inputs,
  ...
}: let
  terminal-oscilloscope = pkgs.stdenv.mkDerivation {
    pname = "terminal-oscilloscope";
    version = "latest";

    src = inputs.terminal-oscilloscope;

    nativeBuildInputs = [pkgs.unstable.nim pkgs.makeWrapper];

    buildInputs = [
      pkgs.unstable.ncurses
      pkgs.unstable.ffmpeg
      pkgs.unstable.fftw
      pkgs.unstable.portaudio
      pkgs.unstable.alsa-lib
    ];

    buildPhase = ''
      # Compile osc.nim and explicitly point it to the injected illwill source
      nim c -d:release --opt:speed \
        --path:${inputs.illwill} \
        --path:${inputs.illwill}/src \
        src/osc.nim
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp src/osc $out/bin/terminal-oscilloscope

      # Wrap the executable so it can find libav via dlopen at runtime
      wrapProgram $out/bin/terminal-oscilloscope \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.ffmpeg]}"
    '';
  };
in {
  home.packages = [
    pkgs.cava
    terminal-oscilloscope
  ];
}
