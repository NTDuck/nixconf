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
      # Added --out:terminal-oscilloscope to explicitly name the output binary
      nim c -d:release --opt:speed \
        --path:${inputs.illwill} \
        --path:${inputs.illwill}/src \
        --nimcache:.nimcache \
        --out:terminal-oscilloscope \
        src/osc.nim
    '';

    installPhase = ''
      mkdir -p $out/bin
      # Copy the explicitly named binary instead of src/osc
      cp terminal-oscilloscope $out/bin/

      # Wrap the executable so it can find libav via dlopen at runtime
      # (Note: matched pkgs.unstable.ffmpeg here to align with your buildInputs)
      wrapProgram $out/bin/terminal-oscilloscope \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.unstable.ffmpeg]}"
    '';
  };
in {
  home.packages = [
    pkgs.cava
    terminal-oscilloscope
  ];
}
