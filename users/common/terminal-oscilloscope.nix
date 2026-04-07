{
  pkgs,
  inputs,
  ...
}: let
  terminal-oscilloscope = pkgs.stdenv.mkDerivation {
    pname = "terminal-oscilloscope";
    version = "latest";

    src = inputs.terminal-oscilloscope;

    # Added makeWrapper to handle the NixOS dlopen quirk
    nativeBuildInputs = [pkgs.unstable.nim pkgs.makeWrapper];

    # We include ffmpeg because the app requires libavdevice/libavformat
    # We include illwill in case the repo doesn't vendor it
    buildInputs = [
      pkgs.unstable.ncurses
      pkgs.unstable.ffmpeg
      pkgs.unstable.fftw
      pkgs.unstable.portaudio
      pkgs.unstable.alsa-lib
    ];

    buildPhase = ''
      # The source file was renamed to osc.nim by the developer
      nim c -d:release --opt:speed src/osc.nim
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
    terminal-oscilloscope
  ];
}
