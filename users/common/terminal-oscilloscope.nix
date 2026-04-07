{
  pkgs,
  inputs,
  ...
}: let
  terminal-oscilloscope = pkgs.stdenv.mkDerivation {
    pname = "terminal-oscilloscope";
    version = "latest";

    src = inputs.terminal-oscilloscope;

    # Bring makeWrapper back
    nativeBuildInputs = [pkgs.unstable.nim pkgs.makeWrapper];

    buildInputs = [
      pkgs.unstable.ncurses
      # The Fix: Pin to FFmpeg 6 so it perfectly matches the .60 requirement
      pkgs.unstable.ffmpeg_6
      pkgs.unstable.fftw
      pkgs.unstable.portaudio
      pkgs.unstable.alsa-lib
    ];

    buildPhase = ''
      # Back to a clean, simple compile command
      nim c -d:release --opt:speed \
        --path:${inputs.illwill} \
        --path:${inputs.illwill}/src \
        --nimcache:.nimcache \
        --out:terminal-oscilloscope \
        src/osc.nim
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp terminal-oscilloscope $out/bin/

      # Wrap the binary so it sees our specifically pinned FFmpeg 6 libraries
      wrapProgram $out/bin/terminal-oscilloscope \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.unstable.ffmpeg_6]}"
    '';
  };
in {
  home.packages = [
    terminal-oscilloscope
  ];
}
