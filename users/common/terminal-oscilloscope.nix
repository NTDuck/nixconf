{
  pkgs,
  inputs,
  ...
}: let
  terminal-oscilloscope = pkgs.stdenv.mkDerivation {
    pname = "terminal-oscilloscope";
    version = "latest";

    src = inputs.terminal-oscilloscope;

    # makeWrapper is no longer needed!
    nativeBuildInputs = [pkgs.unstable.nim];

    buildInputs = [
      pkgs.unstable.ncurses
      pkgs.unstable.ffmpeg
      pkgs.unstable.fftw
      pkgs.unstable.portaudio
      pkgs.unstable.alsa-lib
    ];

    buildPhase = ''
      # --dynlibOverride neuters the fragile, hardcoded version strings.
      # --passL forces the C compiler to link the libraries natively.
      # Nix will automatically bake the correct absolute paths into the binary.
      nim c -d:release --opt:speed \
        --path:${inputs.illwill} \
        --path:${inputs.illwill}/src \
        --nimcache:.nimcache \
        --out:terminal-oscilloscope \
        --dynlibOverride:avdevice \
        --dynlibOverride:avformat \
        --dynlibOverride:avcodec \
        --dynlibOverride:avutil \
        --dynlibOverride:swresample \
        --dynlibOverride:portaudio \
        --dynlibOverride:fftw3 \
        --passL:-lavdevice \
        --passL:-lavformat \
        --passL:-lavcodec \
        --passL:-lavutil \
        --passL:-lswresample \
        --passL:-lportaudio \
        --passL:-lfftw3 \
        src/osc.nim
    '';

    installPhase = ''
      mkdir -p $out/bin
      # No wrapping required! The binary is perfectly pure.
      cp terminal-oscilloscope $out/bin/
    '';
  };
in {
  home.packages = [
    terminal-oscilloscope
  ];
}
