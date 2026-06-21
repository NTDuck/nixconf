{den, ...}: {
  den.aspects.dev = {
    includes = [
      den.aspects.agentics
      den.aspects.gits
      den.aspects.toolchains
      den.aspects.virtualizations

      den.aspects.cloudflare-warp
      den.aspects.p7zip
      den.aspects.pandoc
      den.aspects.speedtest-cli
      den.aspects.ripgrep
      den.aspects.rufus
      den.aspects.texlive
    ];
  };
}
